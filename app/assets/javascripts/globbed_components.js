require('babel-polyfill');
window.React = require('react');
window.ReactDOMServer = require('react-dom/server');
window.Select = require('react-select');

var bulk = require('bulk-require');
var components = bulk(__dirname, [ './src/app/components/**/*.js' ]);

for (var obj in components) {
    if (components.hasOwnProperty(obj)) {
        mineForFunctions(obj);
    }
}

function mineForFunctions(obj) {
    for (var k in obj)
    {
        if (typeof obj[k] == "object" && obj[k] !== null) {
            mineForFunctions(obj[k]);
        } else if (typeof obj[k] == "function") {
            window[k] = obj[k]
        }
    }
}
