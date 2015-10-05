/*globals ReactRailsUJS*/
import React from 'react/react-with-addons';
import alert from './application/alert';
import ui from './application/ui';
import n from './application/notifications';
import activity_feed from './application/activity_feed';
import m from './application/motions';
import iso from './application/briarcliff/isotope-briarcliff';
import ReactUJS from 'argu/react_ujs.js';
import BGLoaded from 'application/briarcliff/bg-loaded'
import Meta from 'application/meta'

window.Argu = window.Argu || {};
window.Argu.alert = window.Argu.alert || alert;
window.Argu.ui = window.Argu.ui || ui;
window.Argu.n = window.Argu.n || n;
window.Argu.activity_feed = window.Argu.activity_feed || activity_feed;
window.Argu.m = window.Argu.m || m;
window.Argu.iso = window.Argu.iso || iso;

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

window.Argu.shallowMountComponents = shallowMountComponents;
window.Argu.shallowUnmountComponents = shallowUnmountComponents;

//Lets the CSS selector know whether javascript is enabled
document.body.className = document.body.className.replace("no-js","js");

function init () {
    "use strict";

    // All init functions can rest assured that the document is ready.
    try {
        console.log('start init', typeof ReactUJS);
        ReactUJS(document, window);
        window.ReactRailsUJS.mountComponents();
        console.log('ReactUJS init complete');
        Argu.alert.init();
        Argu.ui.init();
        Argu.n.init();

        Argu.activityFeed.init();
        Argu.m.init();
        console.log('calling iso');
        Argu.iso();
    } catch (error) {
        console.log(error);
        console.log('Something went wrong during initialisation');
    }

    function refreshCurrentActor () {
        fetch('/c_a.json', safeCredentials())
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
        .on('pjax:beforeReplace', Meta.processContentForMetaTags)
        .on('pjax:end', shallowMountComponents)
        .on('pjax:end', Meta.removeMetaContent);

    if (!("ontouchstart" in document.documentElement)) {
        document.documentElement.className += " no-touch";
    }
}

export default function () {
    window.Argu = window.Argu || {};
    window.Argu.init = init;
    return {
        init: init
    };
}
