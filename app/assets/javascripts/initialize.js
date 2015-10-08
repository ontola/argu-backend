/*globals ReactRailsUJS*/
import activityFeed from './application/activity_feed';
import React from 'react/addons';
import fetch from 'whatwg-fetch';
import alert from './application/alert';
import ui from './application/ui';
import n from './application/notifications';
import activity_feed from './application/activity_feed';
import m from './application/motions';
import iso from './application/briarcliff/isotope-briarcliff';
import ReactUJS from './lib/react_ujs.js';
import Meta from './application/meta';
import { safeCredentials, statusSuccess } from './lib/helpers';
import $ from 'jquery/dist/jquery'
import Pjax from 'pjax';

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

function init () {
    // All init functions can rest assured that the document is ready.
    try {
        //ReactUJS(document, window);
        //window.ReactRailsUJS.mountComponents();
        alert.init();
        ui.init();
        n.init();

        activityFeed.init();
        m.init();
    } catch (error) {
        debugger;
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

    let pjax = new Pjax({
        elements: 'a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])',
        selectors: ['#pjax-container']
    });

    $(document)
        .on('pjax:send', shallowUnmountComponents) // pjax:start seems to have come unnecessary
        .on('pjax:send', Meta.processContentForMetaTags)
        .on('pjax:success', shallowMountComponents)
        .on('pjax:success', Meta.removeMetaContent);

    if (!("ontouchstart" in document.documentElement)) {
        document.documentElement.className += " no-touch";
    }
}

export default function moduleInit () {
    return {
        init: init
    };
}
