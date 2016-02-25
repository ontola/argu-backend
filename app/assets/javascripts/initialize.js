/*globals ReactRailsUJS*/
import Mine from './windowize';
Mine();

import activityFeed from './application/activity_feed';
import fetch from 'whatwg-fetch';
import alert from './application/alert';
import ui from './application/ui';
import n from './application/notifications';
import activity_feed from './application/activity_feed';
import m from './application/motions';
import iso from './application/briarcliff/isotope-briarcliff';
import Meta from './application/meta';
import { safeCredentials, statusSuccess } from './src/app/lib/helpers';

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
        console.log('Something went wrong during initialisation', error);
    }

    if (!("ontouchstart" in document.documentElement)) {
        document.documentElement.className += " no-touch";
    }
}

export default function moduleInit () {
    return {
        init: init
    };
}
