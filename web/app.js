import init, { format, FormatterConfig, IfStyle, TupleStyle } from './pkg/elmfmt.js';

let wasmReady = false;

// Style examples for preview
const ifStyleExamples = {
    indented: `if condition
  then expr1
  else expr2

-- Chained:
if cond1
  then expr1
  else if cond2
    then expr2
    else expr3`,
    hanging: `if condition then
    expr1
else
    expr2

-- Chained:
if cond1 then
    expr1
else if cond2 then
    expr2
else
    expr3`
};

const tupleStyleExamples = {
    spaced: `point = ( 1, 2, 3 )

-- Multi-line:
coords =
    ( x
    , y
    , z
    )`,
    compact: `point = (1, 2, 3)

-- Multi-line:
coords =
    ( x
    , y
    , z
    )`
};

// DOM elements
const inputEl = document.getElementById('input');
const outputEl = document.getElementById('output');
const formatBtn = document.getElementById('format-btn');
const copyBtn = document.getElementById('copy-btn');
const indentationEl = document.getElementById('indentation');
const ifStyleEl = document.getElementById('if-style');
const tupleStyleEl = document.getElementById('tuple-style');
const newlinesDeclEl = document.getElementById('newlines-between-decls');
const errorContainer = document.getElementById('error-container');
const errorMessage = document.getElementById('error-message');
const loadingEl = document.getElementById('loading');
const ifStylePreview = document.getElementById('if-style-preview');
const tupleStylePreview = document.getElementById('tuple-style-preview');

// Update style previews
function updatePreviews() {
    ifStylePreview.textContent = ifStyleExamples[ifStyleEl.value];
    tupleStylePreview.textContent = tupleStyleExamples[tupleStyleEl.value];
}

// Show error message
function showError(message) {
    errorMessage.textContent = message;
    errorContainer.classList.remove('hidden');
}

// Hide error message
function hideError() {
    errorContainer.classList.add('hidden');
}

// Get current config from form
function getConfig() {
    const config = new FormatterConfig();
    config.indentation = parseInt(indentationEl.value, 10) || 2;
    config.if_style = ifStyleEl.value === 'hanging' ? IfStyle.Hanging : IfStyle.Indented;
    config.tuple_style = tupleStyleEl.value === 'compact' ? TupleStyle.Compact : TupleStyle.Spaced;
    config.newlines_between_decls = parseInt(newlinesDeclEl.value, 10) || 2;
    return config;
}

// Format the code
function formatCode() {
    if (!wasmReady) {
        showError('Formatter is still loading...');
        return;
    }

    hideError();
    const code = inputEl.value;

    if (!code.trim()) {
        outputEl.value = '';
        return;
    }

    try {
        const config = getConfig();
        const result = format(code, config);

        if (result.success) {
            outputEl.value = result.output;
        } else {
            showError(result.error);
            outputEl.value = '';
        }
    } catch (e) {
        showError(e.message || 'An unexpected error occurred');
        outputEl.value = '';
    }
}

// Copy output to clipboard
async function copyOutput() {
    const text = outputEl.value;
    if (!text) return;

    try {
        await navigator.clipboard.writeText(text);
        copyBtn.textContent = 'Copied!';
        copyBtn.classList.add('copied');
        setTimeout(() => {
            copyBtn.textContent = 'Copy';
            copyBtn.classList.remove('copied');
        }, 2000);
    } catch (e) {
        showError('Failed to copy to clipboard');
    }
}

// Initialize WASM module
async function initWasm() {
    loadingEl.classList.remove('hidden');
    formatBtn.disabled = true;

    try {
        await init();
        wasmReady = true;
        loadingEl.classList.add('hidden');
        formatBtn.disabled = false;

        // Format the initial example
        formatCode();
    } catch (e) {
        loadingEl.classList.add('hidden');
        showError(`Failed to load formatter: ${e.message}`);
    }
}

// Event listeners
formatBtn.addEventListener('click', formatCode);
copyBtn.addEventListener('click', copyOutput);

// Format on Ctrl+Enter / Cmd+Enter
inputEl.addEventListener('keydown', (e) => {
    if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
        e.preventDefault();
        formatCode();
    }
});

// Update previews when style changes
ifStyleEl.addEventListener('change', updatePreviews);
tupleStyleEl.addEventListener('change', updatePreviews);

// Auto-format on settings change (optional, can be enabled)
// [indentationEl, ifStyleEl, tupleStyleEl, newlinesDeclEl].forEach(el => {
//     el.addEventListener('change', formatCode);
// });

// Initialize
updatePreviews();
initWasm();
