/*globals $, Bugsnag, ga */
import Mine from './windowize';
Mine();

import 'whatwg-fetch';
import './application/meta';
import activityFeed from './application/activity_feed';
import alert from './application/alert';
import ui from './application/ui';
import n from './application/notifications';
import m from './application/motions';
import iso from './application/briarcliff/isotope-briarcliff';
import introJs from './application/briarcliff/introjs-briarcliff';

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
