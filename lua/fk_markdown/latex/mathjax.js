#!/usr/bin/env node
// MathJax LaTeX → SVG renderer for fk_markdown.nvim
// Usage: echo "E = mc^2" | node mathjax.js
//    or: node mathjax.js "E = mc^2"
//
// Outputs SVG to stdout. Pipe to rsvg-convert for PNG.

const { argv, stdin, stdout, stderr, exit } = require('process');

let input = '';

function render(latex) {
    try {
        const mjPath = require.resolve('mathjax');
        const MathJax = require(mjPath);
        // MathJax 3 API
        if (MathJax.tex2svg) {
            const svg = MathJax.tex2svg(latex, { display: true });
            const adaptor = MathJax.startup.adaptor;
            const svgStr = adaptor.outerHTML(svg);
            stdout.write(svgStr);
        } else {
            stderr.write('MathJax API not supported. Install mathjax@3.\n');
            exit(1);
        }
    } catch (e) {
        // Fallback: try mathjax-node
        try {
            const mjn = require('mathjax-node');
            mjn.config({ MathJax: {} });
            mjn.start();
            mjn.typeset({
                math: latex,
                format: 'TeX',
                svg: true,
            }, function(data) {
                if (data.errors) {
                    stderr.write(data.errors.join('\n') + '\n');
                    exit(1);
                }
                stdout.write(data.svg);
            });
        } catch (e2) {
            stderr.write('Neither mathjax@3 nor mathjax-node found.\n');
            stderr.write('Install with: npm install -g mathjax-node\n');
            exit(1);
        }
    }
}

stdin.setEncoding('utf8');
stdin.on('data', (chunk) => { input += chunk; });
stdin.on('end', () => {
    const fromArgv = argv.length > 2 ? argv.slice(2).join(' ') : '';
    render((input || fromArgv).trim());
});
