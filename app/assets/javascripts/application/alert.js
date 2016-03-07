/*global $, Argu*/
import Alert from '../src/app/components/Alert';

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
        .ajaxComplete(this.handleJSONBody);
};

AlertIntegration.fade = function (duration, _alert) {
    const fadeNow = function(a) {
        a.addClass('alert-hidden');
        window.setTimeout(function(a) {
            a.remove();
        }, 2000, a);
    };

    var timeoutHandle = window.setTimeout(fadeNow, duration, _alert);

    _alert[0].addEventListener('mouseover', function () {
        window.clearTimeout(timeoutHandle);
    });

    _alert[0].addEventListener('mouseout', function () {
        timeoutHandle = window.setTimeout(fadeNow, 1000, _alert)
    });
};

AlertIntegration.fadeAll = function () {
    $(".alert").slideDown(function () {
        AlertIntegration.fade(3000, $(this));
    });
};

AlertIntegration.handleJSONBody = function (event, XMLHttpRequest) {
    try {
        var res = $.parseJSON(XMLHttpRequest.responseText);
        if (res !== undefined &&
            res.notifications !== undefined) {
            res.notifications.forEach(function (notification) {
                new Alert(notification.message, notification.type, true);
            });
        }
    } catch(e) {
        Bugsnag.notifyException(e);
    }
};

export default AlertIntegration;
