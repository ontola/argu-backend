import React from 'react';
import ReactDOM from 'react-dom';

var bulk = require('bulk-require');
var components = bulk(__dirname, ['./src/app/components/**/*.js']);

function mine () {
    window.React = React;
    window.ReactDOM = ReactDOM;
    for (var obj in components) {
        if (components.hasOwnProperty(obj)) {
            mineForFunctions(obj);
        }
    }
}

function mineForFunctions(obj) {
    for (var k in obj)
    {
        if (typeof obj[k] == 'object' && obj[k] !== null) {
            mineForFunctions(obj[k]);
        } else if (typeof obj[k] == 'function') {
            window[k] = obj[k]
        }
    }
}

export default mine;
