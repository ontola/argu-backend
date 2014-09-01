define(function () {

    'use strict';
    return function () {
        return function (scribe) {
            scribe.htmlFormatter.formatters.push(function (html) {
                return html.replace(/(\b[class|style]+)\s*=\s*("[^"]*"|'[^']*'|[\w\-.:]+)/g, ' ');
            });
        };
    };

});