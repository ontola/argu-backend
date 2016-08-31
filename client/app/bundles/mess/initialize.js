/* globals $, Bugsnag, ga, fetch */
import './application/meta';
import activityFeed from './application/activity_feed';
import alert from './application/alert';
import ui from './application/ui';
import iso from './application/briarcliff/isotope-briarcliff';
import introjsBriarcliff from './application/briarcliff/introjs-briarcliff';

(function init() {
    // All init functions can rest assured that the document is ready.
  try {
    alert.init();
    ui.init();
    activityFeed.init();
    iso();
    introjsBriarcliff();
    if (typeof ga === 'function') {
      let first = true;
      $(document).on('turbolinks:load', () => {
        ga('set', 'location', window.location.pathname);
        if (first) {
          first = false;
        } else {
          ga('send', 'pageview');
        }
      });
    }
  } catch (error) {
    console.error('Something went wrong during initialisation', error);
    Bugsnag.notifyException(error);
  }

  if (!('ontouchstart' in document.documentElement)) {
    document.documentElement.className += ' no-touch';
  }
})();
