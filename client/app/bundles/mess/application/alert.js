/* global $, Alert, Bugsnag */
const AlertIntegration = {};

const ALERT_FADE_TO = 3000;
const ALERT_FADE_TO_AFTER_MO = 2000;
const ALERT_REMOVE_TO = 2000;

AlertIntegration.init = function init() {
  const fadeOnStart = () => {
    this.fadeAll();
    document.removeEventListener('mousemove', fadeOnStart, false);
    document.removeEventListener('keydown', fadeOnStart, false);
    document.removeEventListener('touchstart', fadeOnStart, false);
  };
  document.addEventListener('mousemove', fadeOnStart, false);
  document.addEventListener('keydown', fadeOnStart, false);
  document.addEventListener('touchstart', fadeOnStart, false);

  $(document)
        .on('turbolinks:visit', this.fadeAll)
        .on('click', '.alert-close', e => {
          AlertIntegration.fadeNow(e);
        })
        .ajaxComplete(this.handleJSONBody);
};

AlertIntegration.fade = function fade(duration, alert) {
  let timeoutHandle = window.setTimeout(AlertIntegration.fadeNow, duration, alert);

  alert[0].addEventListener('mouseover', () => {
    window.clearTimeout(timeoutHandle);
  });

  alert[0].addEventListener('mouseout', () => {
    timeoutHandle = window.setTimeout(AlertIntegration.fadeNow, ALERT_FADE_TO_AFTER_MO, alert);
  });
};

AlertIntegration.fadeNow = function fadeNow(a) {
  a.addClass('alert-hidden');
  window.setTimeout(elem => {
    elem.remove();
  }, ALERT_REMOVE_TO, a);
};

AlertIntegration.fadeAll = function fadeAll() {
  $('.alert').slideDown(() => {
    AlertIntegration.fade(ALERT_FADE_TO, $(this));
  });
};

AlertIntegration.handleJSONBody = function handleJSONBody(event, XMLHttpRequest) {
  try {
    const contentType = XMLHttpRequest.getResponseHeader('Content-Type');
    if (contentType && contentType.includes('application/json')) {
      const res = JSON.parse(XMLHttpRequest.responseText);
      if (res &&
                Array.isArray(res.notifications)) {
        res.notifications.forEach(notification => {
          new Alert(notification.message, notification.type, true);
        });
      }
    }
  } catch (e) {
    Bugsnag.notifyException(e);
  }
};

export default AlertIntegration;
