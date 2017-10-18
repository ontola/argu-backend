/*globals $, Bugsnag, ga */
import 'whatwg-fetch';
import 'scroll-triggers';
import './application/meta';
import './application/briarcliff/introjs-briarcliff';
import activityFeed from './application/activity_feed';
import alert from './application/alert';
import ui from './application/ui';
import n from './application/notifications';
import transition from './application/transition';
import iso from './application/briarcliff/isotope-briarcliff';

function init () {
    // All init functions can rest assured that the document is ready.
    [transition, alert, ui, n, activityFeed].forEach(module => {
        window.setTimeout(() => {
            try {
                module.init();
            } catch (error) {
                console.error('Something went wrong during initialisation', error);
                Bugsnag.notifyException(error);
            }
        }, 0)
    });
    try {
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
