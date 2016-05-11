require('babel-polyfill');
window.Intl = require('intl');
window.React = require('react');
window.ReactDOMServer = require('react-dom/server');
window.Select = require('react-select');
window.Map = require('es6-map');

const bulk = require('bulk-require');
const components = bulk(__dirname, ['./src/app/components/**/*.js']);

for (const obj in components) {
    if (components.hasOwnProperty(obj)) {
        mineForFunctions(obj);
    }
}

function mineForFunctions(subObj) {
    for (const k in subObj)
    {
        if (typeof subObj[k] == 'object' && subObj[k] !== null) {
            mineForFunctions(subObj[k]);
        } else if (typeof subObj[k] == 'function') {
            window[k] = subObj[k]
        }
    }
}
