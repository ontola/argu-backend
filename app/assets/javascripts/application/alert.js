/*global $, Argu*/
import Alert, {
  ALERT_FADE_TIMEOUT,
  ALERT_QUICKFADE_TIMEOUT
} from '../src/app/components/Alert';

let AlertIntegration = {};

AlertIntegration.init =  function () {
    let _this = this;
    function fadeOnStart () {
        _this.fadeAll();
        document.removeEventListener('mousemove', fadeOnStart, false);
        document.removeEventListener('keydown', fadeOnStart, false);
        document.removeEventListener('touchstart', fadeOnStart, false);
    }
    document.addEventListener('mousemove', fadeOnStart, false);
    document.addEventListener('keydown', fadeOnStart, false);
    document.addEventListener('touchstart', fadeOnStart, false);

    $(document)
        .on('turbolinks:visit', this.fadeAll)
        .on('click', '.alert-close', e => {
          AlertIntegration.fadeNow($(e.target).closest('.alert'));
        })
        .ajaxComplete(this.handleJSONBody);
};

AlertIntegration.fade = function (duration, _alert) {
    var timeoutHandle = window.setTimeout(AlertIntegration.fadeNow, duration, _alert);

    _alert[0].addEventListener('mouseover', function () {
        window.clearTimeout(timeoutHandle);
    });

    _alert[0].addEventListener('mouseout', function () {
        timeoutHandle = window.setTimeout(
          AlertIntegration.fadeNow,
          ALERT_QUICKFADE_TIMEOUT,
          _alert
        );
    });
};

AlertIntegration.fadeNow = function(a) {
    a.addClass('alert-hidden');
    window.setTimeout(function(a) {
        a.remove();
    }, ALERT_FADE_TIMEOUT, a);
};

AlertIntegration.fadeAll = function () {
    $('.alert').slideDown(function () {
        AlertIntegration.fade(3000, $(this));
    });
};

AlertIntegration.handleJSONBody = function (event, XMLHttpRequest) {
    try {
        let contentType = XMLHttpRequest.getResponseHeader('Content-Type');
        if (contentType && contentType.includes('application/json')) {
            var res = JSON.parse(XMLHttpRequest.responseText);
            if (res &&
                Array.isArray(res.notifications)) {
                res.notifications.forEach(function (notification) {
                    new Alert(notification.message, notification.type, true);
                });
            }
        }
    } catch(e) {
        Bugsnag.notifyException(e);
    }
};

export default AlertIntegration;
