// ==UserScript==
// @name         Ultimate HTML5 Speed Hack for Tribals.io
// @namespace    http://tampermonkey.net/
// @version      2.0
// @description  Truly extreme speed hack by forcing game loops (J=normal, L=max speed, K=toggle UI) for HTML5 games like Tribals.io
// @author       You
// @match        https://tribals.io/*
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function () {
    'use strict';

    let speedMultiplier = 1.0;
    let forceUltraSpeed = false;

    // Monkey-patch Date and performance
    const originalDateNow = Date.now;
    const originalPerfNow = performance.now.bind(performance);
    Date.now = () => originalDateNow() * speedMultiplier;
    performance.now = () => originalPerfNow() * speedMultiplier;

    // Adjust timeout & interval
    const originalSetTimeout = window.setTimeout;
    const originalSetInterval = window.setInterval;
    window.setTimeout = (fn, delay, ...args) => originalSetTimeout(fn, delay / speedMultiplier, ...args);
    window.setInterval = (fn, delay, ...args) => originalSetInterval(fn, delay / speedMultiplier, ...args);

    // requestAnimationFrame hack
    const originalRAF = window.requestAnimationFrame;
    window.requestAnimationFrame = function (callback) {
        if (!forceUltraSpeed) {
            return originalRAF((t) => callback(t * speedMultiplier));
        } else {
            // Loop like crazy
            const loop = () => callback(originalPerfNow() * speedMultiplier);
            setTimeout(loop, 0); // force tight loop (0ms delay)
        }
    };

    // UI
    window.addEventListener('load', () => {
        const container = document.createElement('div');
        container.style.cssText = `
            position: fixed; top: 20px; left: 20px;
            background: black;
            color: white;
            border: 4px solid;
            border-image: linear-gradient(to right, red 50%, lightblue 50%) 1;
            padding: 10px;
            font-family: Arial, sans-serif;
            z-index: 9999;
        `;

        const label = document.createElement('div');
        label.textContent = 'Speed: 1.00x';
        label.style.marginBottom = '6px';

        const slider = document.createElement('input');
        slider.type = 'range';
        slider.min = '1';
        slider.max = '10000';
        slider.step = '1';
        slider.value = '100';
        slider.style.width = '300px';

        slider.addEventListener('input', () => {
            speedMultiplier = parseFloat(slider.value) / 100;
            label.textContent = `Speed: ${speedMultiplier.toFixed(2)}x`;
        });

        container.appendChild(label);
        container.appendChild(slider);
        document.body.appendChild(container);

        document.addEventListener('keydown', (e) => {
            const key = e.key.toLowerCase();
            if (key === 'k') {
                container.style.display = container.style.display === 'none' ? 'block' : 'none';
            } else if (key === 'l') {
                slider.value = '10000'; // 100.00x
                speedMultiplier = 100.0;
                forceUltraSpeed = true;
                label.textContent = `Speed: ${speedMultiplier.toFixed(2)}x (Ultra Mode ⚡)`;
            } else if (key === 'j') {
                slider.value = '100';
                speedMultiplier = 1.0;
                forceUltraSpeed = false;
                label.textContent = `Speed: 1.00x`;
            }
        });
    });
})();
