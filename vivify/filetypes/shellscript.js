/*
 * filetypes/shellscript.js
 *
 * Shell script highlighting for Vivify.
 *
 * Highlights:
 *   - fenced code blocks tagged sh, bash, shell, shellscript, zsh, ksh, dash
 *   - standalone files: *.sh, *.bash, *.zsh, *.ksh, .bashrc, .bash_profile,
 *     .bash_aliases, .zshrc, .zshenv, .zprofile, .profile, .envrc
 *   - other filetypes can reuse it: it registers itself as
 *     window.VivifyFiletypes.shellscript (filetypes/just.js uses it for
 *     recipe bodies).
 *
 * Tokens are emitted as <span class="sh-*">; colors live in
 * filetypes/shellscript.css.
 *
 * Config (~/.config/vivify/config.json):
 *   {
 *     "scripts": "filetypes/*.js",
 *     "styles": ["themes/*.css", "filetypes/*.css"]
 *   }
 * Restart Vivify afterwards (`pkill -f vivify-server`, then run `viv`).
 *
 * API (all functions are pure; state is explicit so callers can feed lines
 * one at a time):
 *   newState()                -> state object for line()
 *   line(text, state, hooks)  -> HTML for one line
 *   highlight(src, hooks)     -> HTML for a whole script
 *   isShellShebang(line)      -> does a `#!` line select a shell?
 * hooks (optional) lets a host language embed its own syntax in shell text:
 *   { trigger: '{{', interpAt(text, i) -> { html, end } | null }
 */
(() => {
  'use strict';

  // ---------------------------------------------------------------- helpers
  const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  const sp = (cls, text) => `<span class="${cls}">${esc(text)}</span>`;

  const KEYWORDS = new Set([
    'if', 'then', 'else', 'elif', 'fi', 'for', 'while', 'until', 'do', 'done', 'case', 'esac',
    'select', 'function', 'time',
  ]);
  const BUILTINS = new Set([
    'alias', 'bg', 'bind', 'break', 'builtin', 'cd', 'command', 'continue', 'declare', 'dirs', 'echo',
    'enable', 'eval', 'exec', 'exit', 'export', 'false', 'fg', 'getopts', 'hash', 'history', 'jobs',
    'kill', 'let', 'local', 'popd', 'printf', 'pushd', 'pwd', 'read', 'readonly', 'return', 'set',
    'shift', 'shopt', 'source', 'test', 'times', 'trap', 'true', 'type', 'typeset', 'ulimit', 'umask',
    'unalias', 'unset', 'wait',
  ]);
  // After these, the next word is again a command (or an assignment).
  const CMD_AFTER = new Set([
    'if', 'then', 'do', 'else', 'elif', 'while', 'until', 'time', 'export', 'local', 'declare',
    'readonly', 'typeset', 'exec', 'command', 'builtin', 'sudo', 'doas', 'env', 'nohup', 'nice', 'xargs',
  ]);
  const SHELL_INTERPRETERS = new Set(['sh', 'bash', 'zsh', 'dash', 'ksh', 'ash', 'busybox']);

  const RE_SHVAR = /\$(?:\{[^}]*\}|[A-Za-z_]\w*|[0-9@#?*!$-])/y;
  const RE_REDIR = /(?:\d*(?:>>|>|<)&?\d*-?|&>>?)/y;
  const RE_HEREDOC = /<<(-?)[ \t]*(?:'([^']+)'|"([^"]+)"|\\?([A-Za-z_]\w*))/y;
  const RE_FLAG = /-+[\w-]*/y;
  const RE_NUMWORD = /[0-9A-Za-z_.]+/y;
  // A command word: names, paths (./x, /usr/bin/x, ~/bin/x), python3.11, g++
  const RE_CMD = /[A-Za-z_.\/~][\w.+\/~@-]*/y;
  const SHELL_VAR_SPLIT = /(\$(?:\{[^}]*\}|[A-Za-z_]\w*|[0-9@#?*!$-]))/;

  function matchAt(re, s, i) {
    re.lastIndex = i;
    return re.exec(s);
  }

  // Does a `#!` line select a shell? (Non-shell scripts skip command coloring.)
  function isShellShebang(text) {
    const parts = text.replace(/^#!\s*/, '').split(/\s+/);
    let k = 0;
    let prog = (parts[k++] || '').split('/').pop();
    if (prog === 'env') {
      while (k < parts.length && (parts[k].startsWith('-') || parts[k].includes('='))) k++;
      prog = (parts[k] || '').split('/').pop();
    }
    return SHELL_INTERPRETERS.has(prog);
  }

  const withVars = (t) =>
    t.split(SHELL_VAR_SPLIT).map((part, idx) => (idx % 2 ? sp('sh-var', part) : esc(part))).join('');

  // Highlight `text` with `plainFn`, letting the host's interpolation syntax
  // (hooks.interpAt) take over wherever it matches.
  function withInterp(text, plainFn, hooks) {
    if (!hooks || !hooks.interpAt) return plainFn(text);
    let out = '';
    let i = 0;
    while (i < text.length) {
      const r = hooks.interpAt(text, i);
      if (r) {
        out += r.html;
        i = r.end;
        continue;
      }
      let k = text.indexOf(hooks.trigger, i + 1);
      if (k < 0) k = text.length;
      out += plainFn(text.slice(i, k));
      i = k;
    }
    return out;
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

  // Quote spanning from `i` (or continuing one from the previous line).
  function quoted(s, i, q, cont, hooks) {
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
        `<span class="sh-string">${cont ? '' : q}` +
        withInterp(inner, q === '"' ? withVars : esc, hooks) +
        `${closed ? q : ''}</span>`,
      end: closed ? k + 1 : s.length,
      open: closed ? null : q,
    };
  }

  const newState = () => ({ quote: null, heredoc: null, noCmd: false, cont: false });

  // ------------------------------------------------------------------ lines
  function line(s, st, hooks) {
    // inside a heredoc body
    if (st.heredoc) {
      const h = st.heredoc;
      if (s.trim() === h.tag) {
        st.heredoc = null;
        return sp('sh-tag', s);
      }
      return `<span class="sh-string">${withInterp(s, h.expand ? withVars : esc, hooks)}</span>`;
    }

    // shebang: also decides whether the rest is shell at all
    if (!st.quote && s.startsWith('#!')) {
      st.noCmd = !isShellShebang(s);
      st.cont = false;
      return sp('sh-shebang', s);
    }

    const n = s.length;
    const cmdStart = !st.noCmd; // non-shell scripts: no command coloring
    let cmdPos = cmdStart && !st.cont; // is the next word in command position?
    st.cont = false;
    let out = '';
    let i = 0;
    let sawFor = false;
    let nextFunc = false;
    let commented = false;
    let valuePending = false; // just saw FOO= : a quoted/$ value keeps command position

    if (st.quote) {
      const r = quoted(s, 0, st.quote, true, hooks);
      out += r.html;
      i = r.end;
      st.quote = r.open;
      cmdPos = false;
    }

    while (i < n) {
      const c = s[i];

      const ir = hooks && hooks.interpAt ? hooks.interpAt(s, i) : null;
      if (ir) {
        out += ir.html;
        i = ir.end;
        cmdPos = false;
        continue;
      }

      if (c === ' ' || c === '\t') {
        out += c;
        i++;
        valuePending = false;
        continue;
      }

      if (c === '#' && (i === 0 || /\s/.test(s[i - 1]))) {
        out += sp('sh-comment', s.slice(i));
        commented = true;
        break;
      }

      if (c === "'" || c === '"') {
        const r = quoted(s, i, c, false, hooks);
        out += r.html;
        i = r.end;
        st.quote = r.open;
        cmdPos = valuePending && !r.open ? cmdStart : false;
        valuePending = false;
        continue;
      }

      if (c === '$') {
        if (s[i + 1] === '(') {
          const j = closingParen(s, i + 2);
          if (j >= 0) {
            out += sp('sh-subst', '$(') + line(s.slice(i + 2, j), newState(), hooks) + sp('sh-subst', ')');
            i = j + 1;
            cmdPos = valuePending ? cmdStart : false;
            valuePending = false;
            continue;
          }
        }
        const m = matchAt(RE_SHVAR, s, i);
        if (m) {
          out += sp('sh-var', m[0]);
          i += m[0].length;
          cmdPos = valuePending ? cmdStart : false;
          valuePending = false;
          continue;
        }
      }

      if (c === '`') {
        const j = s.indexOf('`', i + 1);
        if (j >= 0) {
          out += sp('sh-subst', '`') + line(s.slice(i + 1, j), newState(), hooks) + sp('sh-subst', '`');
          i = j + 1;
          cmdPos = valuePending ? cmdStart : false;
          valuePending = false;
          continue;
        }
      }

      if (s.startsWith('&&', i) || s.startsWith('||', i)) {
        out += sp('sh-op', s.substr(i, 2));
        i += 2;
        cmdPos = cmdStart;
        continue;
      }

      if (c === '|' || c === ';') {
        out += sp('sh-op', c);
        i++;
        cmdPos = cmdStart;
        continue;
      }

      if (c === '<' && s.startsWith('<<', i) && !s.startsWith('<<<', i)) {
        const m = matchAt(RE_HEREDOC, s, i);
        if (m) {
          const isQuoted = Boolean(m[2] || m[3]);
          st.heredoc = { tag: m[2] || m[3] || m[4], expand: !isQuoted };
          out += sp('sh-op', '<<' + m[1]) + sp('sh-tag', m[0].slice(2 + m[1].length));
          i += m[0].length;
          cmdPos = false;
          continue;
        }
      }

      if (c === '<' || c === '>' || c === '&' || (c >= '0' && c <= '9')) {
        const m = matchAt(RE_REDIR, s, i);
        if (m && m[0]) {
          out += sp('sh-op', m[0]);
          i += m[0].length;
          continue;
        }
        if (c === '&') {
          out += sp('sh-op', '&');
          i++;
          cmdPos = cmdStart;
          continue;
        }
      }

      if (c === '(' || c === '{') {
        out += c;
        i++;
        cmdPos = cmdStart;
        continue;
      }

      // [ ... ] and [[ ... ]] tests
      if (c === '[' && cmdPos) {
        const t = s.startsWith('[[', i) ? '[[' : '[';
        out += sp('sh-builtin', t);
        i += t.length;
        cmdPos = false;
        continue;
      }
      if (c === ']' && i > 0 && /\s/.test(s[i - 1])) {
        const t = s.startsWith(']]', i) ? ']]' : ']';
        out += sp('sh-builtin', t);
        i += t.length;
        cmdPos = false;
        continue;
      }

      if (cmdPos && (c === '.' || c === '/' || c === '~')) {
        const m = matchAt(RE_CMD, s, i);
        if (m) {
          out += m[0] === '.' ? sp('sh-builtin', m[0]) : sp('sh-cmd', m[0]);
          i += m[0].length;
          cmdPos = false;
          continue;
        }
      }

      if (c === '-' && (i === 0 || /[\s=]/.test(s[i - 1]))) {
        const m = matchAt(RE_FLAG, s, i);
        const fm = /^(-[A-Za-z]+)(\d+)$/.exec(m[0]); // -j4, -n10
        out += fm ? esc(fm[1]) + sp('sh-number', fm[2]) : esc(m[0]);
        i += m[0].length;
        cmdPos = false;
        continue;
      }

      if (c >= '0' && c <= '9') {
        const m = matchAt(RE_NUMWORD, s, i);
        out += /^(?:0[xX][0-9a-fA-F]+|[0-9]+(?:\.[0-9]+)*[A-Za-z]{0,3})$/.test(m[0])
          ? sp('sh-number', m[0])
          : esc(m[0]);
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

        if (nextFunc) {
          out += sp('sh-func', w);
          nextFunc = false;
          i = j;
          cmdPos = false;
          continue;
        }

        if (cmdPos && after === '=' && /^[A-Za-z_]\w*$/.test(w)) {
          out += sp('sh-assign', w) + sp('sh-op', '=');
          i = j + 1;
          // swallow a bare value so `FOO=bar BAZ=1 cmd` stays in command position
          const v = /^[^\s;|&()<>"'`$#{]+/.exec(s.slice(i));
          if (v) {
            out += esc(v[0]);
            i += v[0].length;
          }
          valuePending = !v; // `FOO="x" cmd` / `FOO=$X cmd`
          continue; // still in command position
        }

        // function definition: name() { ... }
        if (cmdPos && /^[ \t]*\(\)/.test(s.slice(j))) {
          out += sp('sh-func', w);
          i = j;
          cmdPos = false;
          continue;
        }

        if (!/[./]/.test(before) && !/[./=]/.test(after)) {
          if (cmdPos && KEYWORDS.has(w)) {
            out += sp('sh-keyword', w);
            if (w === 'for' || w === 'case' || w === 'select') sawFor = true;
            if (w === 'function') nextFunc = true;
            cmdPos = CMD_AFTER.has(w) && cmdStart;
            i = j;
            continue;
          }
          if (w === 'in' && sawFor && !cmdPos) {
            out += sp('sh-keyword', w);
            sawFor = false;
            i = j;
            continue;
          }
          if (cmdPos && BUILTINS.has(w)) {
            out += sp('sh-builtin', w);
            cmdPos = CMD_AFTER.has(w) && cmdStart;
            i = j;
            continue;
          }
        }
        if (cmdPos) {
          // any other word in command position is a command (or a path to one)
          const m = matchAt(RE_CMD, s, i);
          out += sp('sh-cmd', m[0]);
          i += m[0].length;
          cmdPos = CMD_AFTER.has(m[0]) && cmdStart;
          continue;
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

    st.cont = !commented && !st.quote && /\\$/.test(s);
    return out;
  }

  function highlight(src, hooks) {
    const st = newState();
    return src
      .replace(/\r\n?/g, '\n')
      .split('\n')
      .map((l) => line(l, st, hooks))
      .join('\n');
  }

  const api = { version: 1, newState, line, highlight, isShellShebang };
  if (typeof window !== 'undefined') {
    (window.VivifyFiletypes = window.VivifyFiletypes || {}).shellscript = api;
  }
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  if (typeof document === 'undefined') return;

  // -------------------------------------------------------------------- DOM
  const LANG_RE = /(?:^|\s)(?:language|lang)-(?:sh|bash|shell|shellscript|zsh|ksh|dash)(?=\s|$)/i;
  const FILE_RE =
    /^(?:.*\.(?:sh|bash|zsh|ksh)|\.(?:bashrc|bash_profile|bash_aliases|bash_logout|zshrc|zshenv|zprofile|zlogin|profile|envrc))$/i;

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

  function apply(code) {
    if (done.has(code) && done.get(code) === code.innerHTML) return;
    code.innerHTML = highlight(code.textContent);
    code.classList.add('language-shellscript');
    done.set(code, code.innerHTML);
  }

  let lastLog = '';
  function scan() {
    const fileName = currentFileName();
    const isShellFile = FILE_RE.test(fileName);
    const stats = { file: fileName, shellFile: isShellFile, pre: 0, matched: 0, unmatched: [] };
    document.querySelectorAll('pre').forEach((pre) => {
      stats.pre++;
      const code = pre.querySelector('code');
      const cls = `${pre.className || ''} ${(code && code.className) || ''}`;
      if (!(LANG_RE.test(cls) || isShellFile)) {
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
      console.info('[shellscript] scan', stats);
    }
  }

  let timer = null;
  const schedule = () => {
    if (timer) return;
    timer = setTimeout(() => {
      timer = null;
      try { scan(); } catch (e) { console.error('[shellscript]', e); }
    }, 30);
  };

  console.info('[shellscript] loaded');
  new MutationObserver(schedule).observe(document.documentElement, { childList: true, subtree: true });
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', schedule);
  else schedule();
})();
