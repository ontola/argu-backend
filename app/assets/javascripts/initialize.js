/*globals ReactRailsUJS*/
import activityFeed from './application/activity_feed';
import React from 'react';
import ReactDOM from 'react-dom';
import fetch from 'whatwg-fetch';
import alert from './application/alert';
import ui from './application/ui';
import n from './application/notifications';
import activity_feed from './application/activity_feed';
import m from './application/motions';
import iso from './application/briarcliff/isotope-briarcliff';
import ReactUJS from './lib/react_ujs.js';
import Meta from './application/meta';
import { safeCredentials, statusSuccess } from './src/app/lib/helpers';

function shallowMountComponents () {
    window.ReactRailsUJS.mountComponents('#pjax-container');
}
window.shallowMountComponents = shallowMountComponents;

function shallowUnmountComponents () {
    window.ReactRailsUJS.unmountComponents('#pjax-container');
}
window.shallowUnmountComponents = shallowUnmountComponents;

function init () {
    // All init functions can rest assured that the document is ready.
    try {
        alert.init();
        ui.init();
        n.init();

        activityFeed.init();
        m.init();
        iso();
    } catch (error) {
        debugger;
        console.log('Something went wrong during initialisation');
    }

    function stopOnJSONError (e, request, error, options) {
        if (request.getResponseHeader('X-PJAX-REFRESH') === 'false') {
            e.preventDefault();
            e.stopPropagation();
        }
    }

    if (typeof $.pjax.defaults ===  'undefined') {
        $.pjax.defaults = {};
    }
    $.pjax.defaults.timeout = 7000;

    $(document)
        .pjax('a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])', '#pjax-container')
        .on('pjax:beforeApply', shallowUnmountComponents) // pjax:start seems to have come unnecessary
        .on('pjax:beforeReplace', Meta.processContentForMetaTags)
        .on('pjax:end', shallowMountComponents)
        .on('pjax:end', Meta.removeMetaContent)
        .on('pjax:error', stopOnJSONError);

    if (!("ontouchstart" in document.documentElement)) {
        document.documentElement.className += " no-touch";
    }
}

export default function moduleInit () {
    return {
        init: init
    };
}
