import React from 'react';
import ReactDOM from 'react-dom';

const bulk = require('bulk-require');
const components = bulk(__dirname,
    ['./src/app/components/**/*.js', './src/app/containers/**/*.js']);

function mine () {
    window.React = React;
    window.ReactDOM = ReactDOM;
    for (const obj in components) {
        if (components.hasOwnProperty(obj)) {
            mineForFunctions(obj);
        }
    }
}

function mineForFunctions(obj) {
    for (const k in obj)
    {
        if (typeof obj[k] == 'object' && obj[k] !== null) {
            mineForFunctions(obj[k]);
        } else if (typeof obj[k] == 'function') {
            window[k] = obj[k]
        }
    }
}

export default mine;
