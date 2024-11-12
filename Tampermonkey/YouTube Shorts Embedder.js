// ==UserScript==
// @name         YouTube Shorts Embedder
// @namespace    http://tampermonkey.net/
// @version      1.0
// @description  Redirect YouTube Shorts pages to embed pages
// @match        https://www.youtube.com/*
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    // Function to redirect to embed URL
    function redirectToEmbed() {
        let currentUrl = window.location.href;
        if (currentUrl.includes('/shorts/')) {
            let newUrl = currentUrl.replace('/shorts/', '/embed/');
            window.location.replace(newUrl);
        }
    }

    // Initial check
    redirectToEmbed();

    // Observe URL changes
    const observer = new MutationObserver(() => {
        redirectToEmbed();
    });

    observer.observe(document, { subtree: true, childList: true });
})();