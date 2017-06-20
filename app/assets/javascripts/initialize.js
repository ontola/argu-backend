/*globals $, Bugsnag, ga */
import mine from './windowize';
mine();

import 'whatwg-fetch';
import 'scroll-triggers';
import './application/meta';
import './application/briarcliff/introjs-briarcliff';
import activityFeed from './application/activity_feed';
import alert from './application/alert';
import ui from './application/ui';
import n from './application/notifications';
import m from './application/motions';
import iso from './application/briarcliff/isotope-briarcliff';

function init () {
    // All init functions can rest assured that the document is ready.
    try {
        alert.init();
        ui.init();
        n.init();

        activityFeed.init();
        m.init();
        iso();
        if (typeof ga === 'function') {
            let first = true;
            $(document).on('turbolinks:load', () => {
                ga('set', 'location', window.location.pathname);
                first ? (first = false) : ga('send', 'pageview');
            });
        }
    } catch (error) {
        console.error('Something went wrong during initialisation', error);
        Bugsnag.notifyException(error);
    }

    if (!('ontouchstart' in document.documentElement)) {
        document.documentElement.className += ' no-touch';
    }
}

export default function moduleInit () {
    return {
        init
    };
}
