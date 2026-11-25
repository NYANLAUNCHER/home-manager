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
hljs.registerLanguage('luau', hljsLuau);
hljs.highlightAll();
