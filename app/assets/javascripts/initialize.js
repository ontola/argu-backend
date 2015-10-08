/*globals ReactRailsUJS*/
import React from 'react/addons';
import fetch from 'whatwg-fetch';
//import alert from './application/alert';
//import ui from './application/ui';
//import n from './application/notifications';
//import activity_feed from './application/activity_feed';
//import m from './application/motions';
//import iso from './application/briarcliff/isotope-briarcliff';
import ReactUJS from './lib/react_ujs.js';
import BGLoaded from './application/briarcliff/bg-loaded';
import Meta from './application/meta';
import { safeCredentials } from './lib/helpers';
import $ from 'jquery/dist/jquery'
import Pjax from 'pjax';

window.Argu = window.Argu || {};
console.log('BUNDLE0');
//window.Argu.alert = window.Argu.alert || alert;
//window.Argu.ui = window.Argu.ui || ui;
//window.Argu.n = window.Argu.n || n;
//window.Argu.activity_feed = window.Argu.activity_feed || activity_feed;
//window.Argu.m = window.Argu.m || m;
//window.Argu.iso = window.Argu.iso || iso;

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
    // All init functions can rest assured that the document is ready.
    try {
        console.log('start init', typeof ReactUJS);
        ReactUJS(document, window);
        window.ReactRailsUJS.mountComponents();
        console.log('ReactUJS init complete');
        //Argu.alert.init();
        //Argu.ui.init();
        //Argu.n.init();
        //
        //Argu.activityFeed.init();
        //Argu.m.init();
        //console.log('calling iso');
        //Argu.iso();
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
    window.Argu = window.Argu || {};
    window.Argu.init = init;
    return {
        init: init
    };
}
