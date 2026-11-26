(async () => {
    const CDN = "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1";

    function loadScript(src) {
        return new Promise((resolve, reject) => {
            const existing = [...document.scripts]
                .find(s => s.src === src);

            if (existing) {
                if (existing.dataset.loaded === "true") {
                    resolve();
                    return;
                }

                existing.addEventListener("load", resolve, { once: true });
                existing.addEventListener("error", reject, { once: true });
                return;
            }

            const script = document.createElement("script");
            script.src = src;
            script.async = false;

            script.onload = () => {
                script.dataset.loaded = "true";
                resolve();
            };

            script.onerror = () => {
                script.remove();
                reject(new Error(`Failed to load ${src}`));
            };

            document.head.appendChild(script);
        });
    }

    // Load Highlight.js.
    await loadScript(`${CDN}/highlight.min.js`);

    // Load additional languages.
    await loadScript(
        "https://unpkg.com/highlightjs-luau/dist/luau.min.js"
    );

    // Highlight all supported languages.
    function highlight(root = document) {
        const blocks = [];

        if (root.matches?.("pre code")) {
            blocks.push(root);
        }

        blocks.push(...root.querySelectorAll("pre code"));

        for (const block of blocks) {
            // Don't override explicitly ignored blocks.
            if (block.classList.contains("nohighlight")) continue;

            // Re-highlight only when necessary.
            if (block.dataset.hljsSource === block.textContent) continue;

            const source = block.textContent;

            block.removeAttribute("data-highlighted");

            // Preserve explicitly assigned languages.
            // Otherwise, let Highlight.js auto-detect.
            block.classList.remove("language-plaintext");

            block.textContent = source;
            hljs.highlightElement(block);

            block.dataset.hljsSource = source;
        }
    }

    // Initial highlighting.
    highlight();

    // Observe dynamically generated content.
    const observer = new MutationObserver(records => {
        for (const record of records) {
            for (const node of record.addedNodes) {
                if (node.nodeType === Node.ELEMENT_NODE) {
                    highlight(node);
                }
            }
        }
    });

    observer.observe(document.body, {
        childList: true,
        subtree: true
    });
})();

(async () => {
function loadScript(src) {
    return new Promise((resolve, reject) => {
        const existing = document.querySelector(`script[src="${src}"]`);

        if (existing) {
            if (existing.dataset.loaded === "true") {
                resolve(existing);
                return;
            }

            existing.addEventListener("load", () => resolve(existing), { once: true });
            existing.addEventListener("error", reject, { once: true });
            return;
        }

        const script = document.createElement("script");
        script.src = src;
        script.async = true;

        script.onload = () => {
            script.dataset.loaded = "true";
            resolve(script);
        };

        script.onerror = () => {
            script.remove();
            reject(new Error(`Failed to load script: ${src}`));
        };

        document.head.appendChild(script);
    });
}

// Load Highlight.js
await loadScript("https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/highlight.min.js");
await loadScript("https://unpkg.com/highlightjs-luau/dist/luau.min.js");

// Usage
hljs.highlightAll();
})()
