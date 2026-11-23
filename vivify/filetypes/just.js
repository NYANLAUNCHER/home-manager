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
 * Just's own syntax (recipes, settings, attributes, expressions, strings,
 * {{ interpolation }}) is highlighted here with hljs-* classes (colors in
 * filetypes/just.css). Recipe bodies are handed to filetypes/shellscript.js,
 * which does the shell highlighting (sh-* classes, colors in
 * filetypes/shellscript.css); {{ }} inside shell text stays just syntax.
 * Without shellscript.js, recipe bodies are left uncolored.
 *
 * Config (~/.config/vivify/config.json):
 *   {
 *     "scripts": "filetypes/*.js",
 *     "styles": ["themes/*.css", "filetypes/*.css"]
 *   }
 * Restart Vivify afterwards (`pkill -f vivify-server`, then run `viv`).
 */
(() => {
  'use strict';

  // ---------------------------------------------------------------- helpers
  const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  const sp = (cls, text) => `<span class="${cls}">${esc(text)}</span>`;

  const IDENT = '[A-Za-z_][A-Za-z0-9_-]*';
  const KEYWORDS = new Set(['if', 'else']);
  const LITERALS = new Set(['true', 'false']);

  // The shell highlighter is looked up lazily so script load order doesn't matter.
  function getShell() {
    if (typeof window !== 'undefined' && window.VivifyFiletypes && window.VivifyFiletypes.shellscript) {
      return window.VivifyFiletypes.shellscript;
    }
    if (typeof module !== 'undefined' && typeof require === 'function') {
      try { return require('./shellscript.js'); } catch (_) { /* not available */ }
    }
    return null;
  }

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
  // {{ interpolation }} inside shell text. `{{{{` is an escaped literal "{{".
  // Returns null when there is no interpolation at `i`.
  function interpAt(t, i) {
    if (!t.startsWith('{{', i)) return null;
    if (t.startsWith('{{{{', i)) return { html: '{{{{', end: i + 4 };
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
  const HOOKS = { trigger: '{{', interpAt };

  // Used only if shellscript.js isn't loaded: no shell coloring, but {{ }} still works.
  function plainLine(s) {
    let out = '';
    let i = 0;
    while (i < s.length) {
      const r = interpAt(s, i);
      if (r) {
        out += r.html;
        i = r.end;
        continue;
      }
      let k = s.indexOf('{{', i + 1);
      if (k < 0) k = s.length;
      out += esc(s.slice(i, k));
      i = k;
    }
    return out;
  }

  function body(line, st) {
    const m = /^([ \t]+)([\s\S]*)$/.exec(line);
    const indent = m[1];
    let rest = m[2];
    const shellApi = getShell();
    if (shellApi && !st.sh) st.sh = shellApi.newState();

    // recipe line prefixes: @ (quiet), - (ignore errors), ? (guard)
    let prefix = '';
    if (!shellApi || (!st.sh.quote && !st.sh.heredoc && !st.sh.cont)) {
      const p = /^[@\-?]+/.exec(rest);
      if (p) {
        prefix = p[0];
        rest = rest.slice(prefix.length);
      }
    }
    const html = shellApi ? shellApi.line(rest, st.sh, HOOKS) : plainLine(rest);
    return indent + (prefix ? sp('hljs-meta', prefix) : '') + html;
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
    st.sh = null; // fresh shell state for the next recipe
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
    const st = { inBody: false, open: null, sh: null };
    return src
      .replace(/\r\n?/g, '\n')
      .split('\n')
      .map((l) => highlightLine(l, st))
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
      return location.pathname.split('/').pop() || '';
    }
  }

  // code element -> the innerHTML we last wrote. If Vivify re-renders (live
  // reload) the content changes and we highlight again; otherwise we skip.
  const done = new WeakMap();
  let shellWaits = 0;
  let timer = null;

  const schedule = (delay = 30) => {
    if (timer) return;
    timer = setTimeout(() => {
      timer = null;
      try { scan(); } catch (e) { console.error('[just]', e); }
    }, delay);
  };

  function apply(code) {
    if (done.has(code) && done.get(code) === code.innerHTML) return;
    // shellscript.js may still be loading: wait a little before falling back
    if (!getShell() && shellWaits < 40) {
      shellWaits++;
      schedule(100);
      return;
    }
    code.innerHTML = highlightJust(code.textContent);
    code.classList.add('language-just');
    done.set(code, code.innerHTML);
  }

  let lastLog = '';
  function scan() {
    const fileName = currentFileName();
    const isJustFile = FILE_RE.test(fileName);
    const stats = { file: fileName, justFile: isJustFile, pre: 0, matched: 0, unmatched: [], shell: Boolean(getShell()) };
    document.querySelectorAll('pre').forEach((pre) => {
      stats.pre++;
      const code = pre.querySelector('code');
      const cls = `${pre.className || ''} ${(code && code.className) || ''}`;
      if (!(LANG_RE.test(cls) || isJustFile)) {
        if (stats.unmatched.length < 5) stats.unmatched.push(cls.trim());
        return;
      }
      stats.matched++;
      if (code) apply(code);
      else if (!pre.children.length) apply(pre); // bare <pre> with only text
    });
    const sig = JSON.stringify(stats);
    if (sig !== lastLog) {
      lastLog = sig;
      console.info('[just] scan', stats);
    }
  }

  console.info('[just] loaded');
  new MutationObserver(() => schedule()).observe(document.documentElement, { childList: true, subtree: true });
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', () => schedule());
  else schedule();
})();
