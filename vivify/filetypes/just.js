// vim: set fdm=manual:
/*
 * filetypes/just.js
 *
 * Syntax highlighting for `just` (https://github.com/casey/just) in Vivify.
 *
 * Highlights:
 *   - fenced code blocks tagged  ```just  or  ```justfile  in Markdown
 *   - standalone files named `justfile` (any capitalization), `.justfile`,
 *     or ending in `.just`
 *
 * Lives in ~/.config/vivify/filetypes/ next to its optional stylesheet
 * (filetypes/just.css). themes/ is reserved for site-wide themes.
 *   {
 *     "scripts": "filetypes/*.js",
 *     "styles": ["themes/*.css", "filetypes/*.css"]
 *   }
 * Restart Vivify afterwards (`pkill -f vivify-server`, then run `viv`).
 *
 * How it works: Vivify's bundled highlight.js has no `just` grammar and its
 * output is already rendered HTML, so this script tokenizes the code text
 * itself and emits the same `hljs-*` classes highlight.js uses. Whatever
 * highlight.js theme Vivify is using therefore colors the result.
 */
(() => {
  'use strict';

  // ---------------------------------------------------------------- helpers
  const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  const sp = (cls, text) => `<span class="${cls}">${esc(text)}</span>`;

  const IDENT = '[A-Za-z_][A-Za-z0-9_-]*';
  const KEYWORDS = new Set(['if', 'else']);
  const LITERALS = new Set(['true', 'false']);
  const SHELL_KEYWORDS = new Set([
    'if', 'then', 'else', 'elif', 'fi', 'for', 'while', 'until', 'do', 'done', 'case', 'esac',
    'select', 'function', 'time',
  ]);

  // ---------------------------------------------------------------- strings
  // just strings: '..' and '''..''' (raw), ".." and """.."""  (escapes),
  // `..` and ```..``` (shell commands). x'..' / x".." are shell-expanded.
  // All of them may span multiple lines.
  function stringStart(s, i) {
    let pre = '';
    if (s[i] === 'x' && /['"]/.test(s[i + 1] || '') && (i === 0 || !/[\w-]/.test(s[i - 1]))) pre = 'x';
    const p = i + pre.length;
    for (const d of ['"""', "'''", '```', '"', "'", '`']) {
      if (s.startsWith(d, p)) return { pre, delim: d, escapes: d[0] === '"' };
    }
    return null;
  }

  function strInner(text, escapes) {
    if (!escapes) return esc(text);
    const re = /\\(?:u\{[0-9a-fA-F]+\}|[\s\S])/g;
    let out = '';
    let last = 0;
    let m;
    while ((m = re.exec(text))) {
      out += esc(text.slice(last, m.index)) + `<span class="hljs-char escape_">${esc(m[0])}</span>`;
      last = re.lastIndex;
    }
    return out + esc(text.slice(last));
  }

  // Reads a string starting at `i` (or continuing one when `cont`).
  // Returns the HTML, the end index, and the open spec if it didn't close.
  function readString(s, i, spec, cont) {
    const start = cont ? i : i + spec.pre.length + spec.delim.length;
    let k = start;
    let close = -1;
    while (k < s.length) {
      if (spec.escapes && s[k] === '\\') { k += 2; continue; }
      if (s.startsWith(spec.delim, k)) { close = k; break; }
      k++;
    }
    const head = cont ? '' : esc(spec.pre + spec.delim);
    if (close < 0) {
      return {
        html: `<span class="hljs-string">${head}${strInner(s.slice(start), spec.escapes)}</span>`,
        end: s.length,
        open: spec,
      };
    }
    return {
      html: `<span class="hljs-string">${head}${strInner(s.slice(start, close), spec.escapes)}${esc(spec.delim)}</span>`,
      end: close + spec.delim.length,
      open: null,
    };
  }

  // ------------------------------------------------------------ expressions
  function exprIdent(word, s, end) {
    if (KEYWORDS.has(word)) return sp('hljs-keyword', word);
    if (LITERALS.has(word)) return sp('hljs-literal', word);
    let j = end;
    while (s[j] === ' ' || s[j] === '\t') j++;
    if (s[j] === '(') return sp('hljs-built_in', word);
    return sp('hljs-variable', word);
  }

  // mode: 'expr'   - assignments, settings, anything expression-like
  //       'header' - the part of a recipe header after its name (params : deps)
  //       'attr'   - an attribute line such as [private] or [group('x')]
  function lex(s, st, mode) {
    const n = s.length;
    let out = '';
    let i = 0;
    let depth = 0;
    let phase = 'params';
    let afterEq = false;
    let depName = false;

    if (st.open) {
      const r = readString(s, 0, st.open, true);
      out += r.html;
      i = r.end;
      st.open = r.open;
    }

    while (i < n) {
      const c = s[i];

      if (c === ' ' || c === '\t') {
        let j = i;
        while (j < n && (s[j] === ' ' || s[j] === '\t')) j++;
        out += s.slice(i, j);
        i = j;
        continue;
      }

      if (c === '#') {
        out += sp('hljs-comment', s.slice(i));
        break;
      }

      const str = stringStart(s, i);
      if (str) {
        const r = readString(s, i, str, false);
        out += r.html;
        i = r.end;
        st.open = r.open;
        if (depth === 0) afterEq = false;
        depName = false;
        continue;
      }

      const two = s.substr(i, 2);
      if (two === ':=' || two === '==' || two === '!=' || two === '=~' || two === '&&' || two === '||') {
        out += sp('hljs-operator', two);
        if (mode === 'header' && depth === 0 && two === '&&') phase = 'deps';
        i += 2;
        continue;
      }

      if (c === ':') {
        out += ':';
        if (mode === 'header' && depth === 0) phase = 'deps';
        i++;
        continue;
      }

      if (c === '=') {
        out += sp('hljs-operator', '=');
        if (mode === 'header' && depth === 0 && phase === 'params') afterEq = true;
        i++;
        continue;
      }

      if (c === '+' || c === '/' || c === '*' || c === '$' || c === '?') {
        out += sp('hljs-operator', c);
        i++;
        continue;
      }

      if (c === '(') {
        depth++;
        if (mode === 'header' && phase === 'deps' && depth === 1) depName = true;
        out += '(';
        i++;
        continue;
      }

      if (c === ')') {
        depth = Math.max(0, depth - 1);
        if (depth === 0) afterEq = false;
        out += ')';
        i++;
        continue;
      }

      if (c >= '0' && c <= '9') {
        let j = i + 1;
        while (j < n && /[0-9._]/.test(s[j])) j++;
        out += sp('hljs-number', s.slice(i, j));
        i = j;
        continue;
      }

      if (/[A-Za-z_]/.test(c)) {
        let j = i + 1;
        while (j < n && /[A-Za-z0-9_-]/.test(s[j])) j++;
        const w = s.slice(i, j);
        let html;
        if (mode === 'attr' && depth === 0) {
          html = sp('hljs-meta', w);
        } else if (mode === 'header' && depth === 0 && phase === 'params' && !afterEq) {
          html = sp('hljs-params', w);
        } else if (mode === 'header' && phase === 'deps' && (depth === 0 || (depth === 1 && depName))) {
          html = sp('hljs-title function_', w);
        } else {
          html = exprIdent(w, s, j);
        }
        out += html;
        depName = false;
        if (depth === 0) afterEq = false;
        i = j;
        continue;
      }

      out += esc(c);
      i++;
    }
    return out;
  }

  // ---------------------------------------------------------- recipe bodies
  // Bodies are shell (or whatever the shebang says); we do a light shell-ish
  // pass and highlight {{ interpolation }} with the expression lexer.
  function interpAt(t, i) {
    if (t.startsWith('{{{{', i)) return { html: '{{{{', end: i + 4 }; // escaped literal "{{"
    const j = t.indexOf('}}', i + 2);
    const inner = j < 0 ? t.slice(i + 2) : t.slice(i + 2, j);
    return {
      html:
        sp('hljs-template-variable', '{{') +
        lex(inner, { open: null }, 'expr') +
        (j < 0 ? '' : sp('hljs-template-variable', '}}')),
      end: j < 0 ? t.length : j + 2,
    };
  }

  function withInterp(text, plainFn) {
    let out = '';
    let i = 0;
    while (i < text.length) {
      if (text.startsWith('{{', i)) {
        const r = interpAt(text, i);
        out += r.html;
        i = r.end;
        continue;
      }
      let k = text.indexOf('{{', i);
      if (k < 0) k = text.length;
      out += plainFn(text.slice(i, k));
      i = k;
    }
    return out;
  }

  const SHELL_VAR_SPLIT = /(\$(?:\{[^}]*\}|[A-Za-z_]\w*|[0-9@#?*!$-]))/;
  const withVars = (t) =>
    t.split(SHELL_VAR_SPLIT).map((part, idx) => (idx % 2 ? sp('hljs-variable', part) : esc(part))).join('');

  const SHELL_BUILTINS = new Set([
    'alias', 'bg', 'bind', 'break', 'builtin', 'cd', 'command', 'continue', 'declare', 'dirs', 'echo',
    'enable', 'eval', 'exec', 'exit', 'export', 'false', 'fg', 'getopts', 'hash', 'history', 'jobs',
    'kill', 'let', 'local', 'popd', 'printf', 'pushd', 'pwd', 'read', 'readonly', 'return', 'set',
    'shift', 'shopt', 'source', 'test', 'times', 'trap', 'true', 'type', 'typeset', 'ulimit', 'umask',
    'unalias', 'unset', 'wait',
  ]);
  // After these, the next word is again a command (or an assignment).
  const CMD_AFTER = new Set([
    'if', 'then', 'do', 'else', 'elif', 'while', 'until', 'time', 'export', 'local', 'declare',
    'readonly', 'typeset', 'exec', 'command', 'builtin', 'sudo', 'env', 'nohup', 'xargs',
  ]);

  const RE_SHVAR = /\$(?:\{[^}]*\}|[A-Za-z_]\w*|[0-9@#?*!$-])/y;
  const RE_REDIR = /(?:\d*(?:>>|>|<)&?\d*-?|&>>?)/y;
  const RE_HEREDOC = /<<(-?)[ \t]*(?:'([^']+)'|"([^"]+)"|\\?([A-Za-z_]\w*))/y;
  const RE_FLAG = /-+[\w-]*/y;
  const RE_NUMWORD = /[0-9A-Za-z_.]+/y;

  function matchAt(re, s, i) {
    re.lastIndex = i;
    return re.exec(s);
  }

  // Index of the ")" matching an already-open "(" (search starts at `from`).
  function closingParen(s, from) {
    let depth = 1;
    for (let k = from; k < s.length; k++) {
      const ch = s[k];
      if (ch === "'") {
        const e = s.indexOf("'", k + 1);
        if (e < 0) return -1;
        k = e;
      } else if (ch === '\\') k++;
      else if (ch === '(') depth++;
      else if (ch === ')' && --depth === 0) return k;
    }
    return -1;
  }

  // Shell quote spanning from `i` (or continuing one from the previous line).
  function shQuoted(s, i, q, cont) {
    const start = cont ? i : i + 1;
    let k = start;
    while (k < s.length && s[k] !== q) {
      if (q === '"' && s[k] === '\\') k++;
      k++;
    }
    const closed = k < s.length;
    const inner = s.slice(start, Math.min(k, s.length));
    return {
      html:
        `<span class="hljs-string">${cont ? '' : q}` +
        withInterp(inner, q === '"' ? withVars : esc) +
        `${closed ? q : ''}</span>`,
      end: closed ? k + 1 : s.length,
      open: closed ? null : q,
    };
  }

  const subState = () => ({ quote: null, heredoc: null });

  // `st` carries quote / heredoc state across the lines of a recipe body.
  function shell(s, st) {
    const n = s.length;
    let out = '';
    let i = 0;
    let cmdPos = true; // is the next word in command position?
    let sawFor = false;

    if (st.quote) {
      const r = shQuoted(s, 0, st.quote, true);
      out += r.html;
      i = r.end;
      st.quote = r.open;
      cmdPos = false;
    }

    while (i < n) {
      const c = s[i];

      if (s.startsWith('{{', i)) {
        const r = interpAt(s, i);
        out += r.html;
        i = r.end;
        cmdPos = false;
        continue;
      }

      if (c === ' ' || c === '\t') {
        out += c;
        i++;
        continue;
      }

      if (c === '#' && (i === 0 || /\s/.test(s[i - 1]))) {
        out += sp('hljs-comment', s.slice(i));
        break;
      }

      if (c === "'" || c === '"') {
        const r = shQuoted(s, i, c, false);
        out += r.html;
        i = r.end;
        st.quote = r.open;
        cmdPos = false;
        continue;
      }

      if (c === '$') {
        if (s[i + 1] === '(') {
          const j = closingParen(s, i + 2);
          if (j >= 0) {
            out += sp('hljs-variable', '$(') + shell(s.slice(i + 2, j), subState()) + sp('hljs-variable', ')');
            i = j + 1;
            cmdPos = false;
            continue;
          }
        }
        const m = matchAt(RE_SHVAR, s, i);
        if (m) {
          out += sp('hljs-variable', m[0]);
          i += m[0].length;
          cmdPos = false;
          continue;
        }
      }

      if (c === '`') {
        const j = s.indexOf('`', i + 1);
        if (j >= 0) {
          out += sp('hljs-variable', '`') + shell(s.slice(i + 1, j), subState()) + sp('hljs-variable', '`');
          i = j + 1;
          cmdPos = false;
          continue;
        }
      }

      if (s.startsWith('&&', i) || s.startsWith('||', i)) {
        out += sp('hljs-operator', s.substr(i, 2));
        i += 2;
        cmdPos = true;
        continue;
      }

      if (c === '|' || c === ';') {
        out += sp('hljs-operator', c);
        i++;
        cmdPos = true;
        continue;
      }

      if (c === '<' && s.startsWith('<<', i) && !s.startsWith('<<<', i)) {
        const m = matchAt(RE_HEREDOC, s, i);
        if (m) {
          const quoted = Boolean(m[2] || m[3]);
          st.heredoc = { tag: m[2] || m[3] || m[4], expand: !quoted };
          out += sp('hljs-operator', '<<' + m[1]) + sp('hljs-string', m[0].slice(2 + m[1].length));
          i += m[0].length;
          cmdPos = false;
          continue;
        }
      }

      if (c === '<' || c === '>' || c === '&' || (c >= '0' && c <= '9')) {
        const m = matchAt(RE_REDIR, s, i);
        if (m && m[0]) {
          out += sp('hljs-operator', m[0]);
          i += m[0].length;
          continue;
        }
        if (c === '&') {
          out += sp('hljs-operator', '&');
          i++;
          cmdPos = true;
          continue;
        }
      }

      if (c === '(' || c === '{') {
        out += c;
        i++;
        cmdPos = true;
        continue;
      }

      if (c === '-' && (i === 0 || /[\s=]/.test(s[i - 1]))) {
        const m = matchAt(RE_FLAG, s, i);
        out += esc(m[0]);
        i += m[0].length;
        cmdPos = false;
        continue;
      }

      if (c >= '0' && c <= '9') {
        const m = matchAt(RE_NUMWORD, s, i);
        out += /^[0-9]+(?:\.[0-9]+)*$/.test(m[0]) ? sp('hljs-number', m[0]) : esc(m[0]);
        i += m[0].length;
        cmdPos = false;
        continue;
      }

      if (/[A-Za-z_]/.test(c)) {
        let j = i + 1;
        while (j < n && /[A-Za-z0-9_-]/.test(s[j])) j++;
        const w = s.slice(i, j);
        const before = s[i - 1] || '';
        const after = s[j] || '';

        if (cmdPos && after === '=' && /^[A-Za-z_]\w*$/.test(w)) {
          out += sp('hljs-variable', w) + sp('hljs-operator', '=');
          i = j + 1;
          // swallow a bare value so `FOO=bar BAZ=1 cmd` stays in command position
          const v = /^[^\s;|&()<>"'`$#{]+/.exec(s.slice(i));
          if (v) {
            out += esc(v[0]);
            i += v[0].length;
          }
          continue; // still in command position: FOO=bar cmd
        }

        if (!/[./]/.test(before) && !/[./=]/.test(after)) {
          if (cmdPos && SHELL_KEYWORDS.has(w)) {
            out += sp('hljs-keyword', w);
            if (w === 'for' || w === 'case' || w === 'select') sawFor = true;
            cmdPos = CMD_AFTER.has(w);
            i = j;
            continue;
          }
          if (w === 'in' && sawFor && !cmdPos) {
            out += sp('hljs-keyword', w);
            sawFor = false;
            i = j;
            continue;
          }
          if (cmdPos && SHELL_BUILTINS.has(w)) {
            out += sp('hljs-built_in', w);
            cmdPos = CMD_AFTER.has(w);
            i = j;
            continue;
          }
        }
        out += esc(w);
        cmdPos = false;
        i = j;
        continue;
      }

      out += esc(c);
      i++;
      cmdPos = false;
    }
    return out;
  }

  function body(line, st) {
    let m = /^([ \t]+)([\s\S]*)$/.exec(line);
    const indent = m[1];
    let rest = m[2];

    if (st.heredoc) {
      const h = st.heredoc;
      if (rest.trim() === h.tag) {
        st.heredoc = null;
        return indent + sp('hljs-string', rest);
      }
      return indent + '<span class="hljs-string">' + withInterp(rest, h.expand ? withVars : esc) + '</span>';
    }

    let prefix = '';
    if (!st.quote) {
      if (/^#!/.test(rest)) return indent + sp('hljs-meta', rest);
      m = /^[@\-?]+/.exec(rest);
      if (m) {
        prefix = m[0];
        rest = rest.slice(prefix.length);
      }
    }
    return indent + (prefix ? sp('hljs-meta', prefix) : '') + shell(rest, st);
  }

  // ------------------------------------------------------------ whole files
  const RE_SET = new RegExp(`^(set)([ \\t]+)(${IDENT})`);
  const RE_EXPORT = /^(export|unexport)([ \t]+)/;
  const RE_ALIAS = new RegExp(`^(alias)([ \\t]+)(${IDENT})([ \\t]*)(:=)([ \\t]*)(${IDENT})`);
  const RE_IMPORT = new RegExp(`^(import|mod)(\\??)([ \\t]+)(?:(${IDENT})(?=[ \\t]|$))?`);
  const RE_ASSIGN = new RegExp(`^(${IDENT})([ \\t]*)(:=)`);
  const RE_HEADER = new RegExp(`^(@?)(${IDENT})`);

  function assignment(line, st) {
    const m = RE_ASSIGN.exec(line);
    if (!m) return null;
    return (
      sp('hljs-variable', m[1]) + m[2] + sp('hljs-operator', ':=') + lex(line.slice(m[0].length), st, 'expr')
    );
  }

  function highlightLine(line, st) {
    if (st.open) return lex(line, st, 'expr'); // inside a multi-line string
    if (/^\s*$/.test(line)) return esc(line); // blank lines don't end a recipe body
    if (/^[ \t]/.test(line)) return st.inBody ? body(line, st) : lex(line, st, 'expr');

    st.inBody = false;
    st.quote = null;
    st.heredoc = null;
    if (line[0] === '#') return sp(line.startsWith('#!') ? 'hljs-meta' : 'hljs-comment', line);
    if (/^\[.*\]\s*(#.*)?$/.test(line)) return lex(line, st, 'attr');

    let m;
    if ((m = RE_SET.exec(line))) {
      return sp('hljs-keyword', m[1]) + m[2] + sp('hljs-attr', m[3]) + lex(line.slice(m[0].length), st, 'expr');
    }
    if ((m = RE_EXPORT.exec(line))) {
      const rest = line.slice(m[0].length);
      return sp('hljs-keyword', m[1]) + m[2] + (assignment(rest, st) ?? lex(rest, st, 'expr'));
    }
    if ((m = RE_ALIAS.exec(line))) {
      return (
        sp('hljs-keyword', m[1]) + m[2] + sp('hljs-title function_', m[3]) + m[4] +
        sp('hljs-operator', m[5]) + m[6] + sp('hljs-title function_', m[7]) +
        lex(line.slice(m[0].length), st, 'expr')
      );
    }
    if ((m = RE_IMPORT.exec(line))) {
      return (
        sp('hljs-keyword', m[1]) + m[2] + m[3] + (m[4] ? sp('hljs-title class_', m[4]) : '') +
        lex(line.slice(m[0].length), st, 'expr')
      );
    }
    const asg = assignment(line, st);
    if (asg !== null) return asg;

    if ((m = RE_HEADER.exec(line)) && line.includes(':')) {
      st.inBody = true;
      return (
        (m[1] ? sp('hljs-meta', m[1]) : '') + sp('hljs-title function_', m[2]) +
        lex(line.slice(m[0].length), st, 'header')
      );
    }
    return lex(line, st, 'expr');
  }

  function highlightJust(src) {
    const st = { inBody: false, open: null, quote: null, heredoc: null };
    return src
      .replace(/\r\n?/g, '\n')
      .split('\n')
      .map((line) => highlightLine(line, st))
      .join('\n');
  }

  // Exposed for testing under Node; harmless in the browser.
  if (typeof module !== 'undefined' && module.exports) module.exports = { highlightJust };
  if (typeof document === 'undefined') return;

  // -------------------------------------------------------------------- DOM
  const LANG_RE = /(?:^|\s)(?:language|lang)-(?:just|justfile)(?=\s|$)/i;
  const FILE_RE = /^(?:justfile|\.justfile|.*\.just)$/i;

  function currentFileName() {
    try {
      return decodeURIComponent(location.pathname).split('/').pop() || '';
    } catch (_) {
      return (location.pathname.split('/').pop() || '');
    }
  }

  // code element -> the innerHTML we last wrote. If Vivify re-renders (live
  // reload) the content changes and we highlight again; otherwise we skip.
  const done = new WeakMap();

  function apply(code) {
    if (done.has(code) && done.get(code) === code.innerHTML) return;
    const html = highlightJust(code.textContent);
    code.innerHTML = html;
    code.classList.add('language-just');
    done.set(code, code.innerHTML);
  }

  function scan() {
    const isJustFile = FILE_RE.test(currentFileName());
    document.querySelectorAll('pre').forEach((pre) => {
      const code = pre.querySelector('code');
      const cls = `${pre.className || ''} ${(code && code.className) || ''}`;
      if (!(LANG_RE.test(cls) || isJustFile)) return;
      if (code) {
        apply(code);
      } else if (!pre.children.length) {
        apply(pre); // bare <pre> with only text
      }
    });
  }

  let timer = null;
  const schedule = () => {
    if (timer) return;
    timer = setTimeout(() => {
      timer = null;
      try { scan(); } catch (e) { console.error('[just-highlight]', e); }
    }, 30);
  };

  new MutationObserver(schedule).observe(document.documentElement, { childList: true, subtree: true });
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', schedule);
  else schedule();
})();
