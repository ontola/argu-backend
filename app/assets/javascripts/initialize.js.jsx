/*globals ReactRailsUJS*/

Argu = window.Argu || {};

function shallowMountComponents () {
    var nodes = document.querySelectorAll('#pjax-container [data-react-class]');

    for (var i = 0; i < nodes.length; ++i) {
        var node = nodes[i];
        var className = node.getAttribute(window.ReactRailsUJS.CLASS_NAME_ATTR);

        // Assume className is simple and can be found at top-level (window).
        // Fallback to eval to handle cases like 'My.React.ComponentName'.
        var constructor = window[className] || eval.call(window, className);
        var propsJson = node.getAttribute(window.ReactRailsUJS.PROPS_ATTR);
        var props = propsJson && JSON.parse(propsJson);

        React.render(React.createElement(constructor, props), node);
    }
}

function shallowUnmountComponents () {
    var nodes = document.querySelectorAll('#pjax-container [data-react-class]');

    for (var i = 0; i < nodes.length; ++i) {
        var node = nodes[i];

        React.unmountComponentAtNode(node);
        // now remove the `data-react-class` wrapper as well
        //node.parentElement && node.parentElement.removeChild(node);
    }
}

//Lets the CSS selector know whether javascript is enabled
document.body.className = document.body.className.replace("no-js","js");

$(function (){
    "use strict";

    // All init functions can rest assured that the document is ready.
    try {
        Argu.alert.init();
        Argu.ui.init();
        Argu.n.init();

        Argu.activityFeed.init();
        Argu.m.init();
    } catch (error) {
        console.log(error);
        console.log('Something went wrong during initialisation');
    }

    function refreshCurrentActor () {
        fetch('/c_a.json', _safeCredentials())
            .then(statusSuccess)
            .then(json)
            .then(Actions.actorUpdate)
            .catch(function () {
                console.log('failed');
            });
    }

    if (typeof($.pjax.defaults) ===  "undefined") {
        $.pjax.defaults = {};
    }
    $.pjax.defaults.timeout = 10000;

    $(document)
        .pjax('a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])', '#pjax-container')
        .on('pjax:beforeReplace', shallowUnmountComponents) // pjax:start seems to have come unnecessary
        .on('pjax:beforeReplace', processContentForMetaTags)
        .on('pjax:end', shallowMountComponents)
        .on('pjax:end', removeMetaContent);

    if (!("ontouchstart" in document.documentElement)) {
        document.documentElement.className += " no-touch";
    }
});
