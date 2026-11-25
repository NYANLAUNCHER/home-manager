// Uses [highlightjs](https://github.com/jannis-baum/Vivify/blob/main/src/routes/viewer.ts) to highlight the filetypes that Vivify doesn't by default
(() => {
    function highlightMissingLanguages() {
        if (!window.hljs) return;

        document.querySelectorAll("pre > code").forEach(code => {
            const pre = code.parentElement;

            // Don't modify blocks already highlighted by Vivify.
            if (
                code.classList.contains("hljs") ||
                code.querySelector(".hljs")
            ) {
                return;
            }

            // Get the language from either the <pre> or <code>.
            let languageClass = [
                ...pre.classList,
                ...code.classList
            ].find(cls => cls.startsWith("language-"));

            if (!languageClass) return;

            let language = languageClass.slice("language-".length);

            // Map languages without a dedicated Highlight.js grammar.
            const aliases = {
                plaintext: null,
                text: null,
                txt: null
            };

            if (Object.hasOwn(aliases, language)) {
                language = aliases[language];
            }

            // Don't attempt to highlight plaintext.
            if (!language) return;

            // Only highlight languages Highlight.js actually knows.
            if (!hljs.getLanguage(language)) return;

            code.classList.add(`language-${language}`);
            hljs.highlightElement(code);
        });
    }

    // Run after the document has loaded.
    if (document.readyState === "loading") {
        document.addEventListener(
            "DOMContentLoaded",
            highlightMissingLanguages
        );
    } else {
        highlightMissingLanguages();
    }
})();
