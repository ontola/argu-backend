/*global $, Argu*/

if(!window.Argu) {
    window.Argu = {};
}

"use strict";

(function() {
    var fade = function (duration, _alert) {
        window.setTimeout(function(a) {
            a.slideUp(function () {
                a.remove();
            });
        }, duration, _alert);
    };

    Argu.Alert = function (message, messageType, instantShow, beforeSelector) {
        var alert = this,
           _alert = undefined,
        _duration = 3000;
        message        = typeof message        !== 'undefined' ? message : '';
        messageType    = typeof messageType    !== 'undefined' ? messageType : 'success';
        instantShow    = typeof instantShow    !== 'undefined' ? instantShow : false;
        beforeSelector = typeof beforeSelector !== 'undefined' ? beforeSelector : '#navbar';

        var render = function () {
            (_alert = $("<pre class='alert alert-" + messageType + "'>" + message + "</pre>")).insertBefore($(beforeSelector));
            return _alert;
        };

        this.hide = function () {
            fade(_duration, _alert);
        };

        this.show = function (duration, autoHide) {
           _duration = typeof duration !== 'undefined' ? duration : _duration;
            autoHide = typeof autoHide !== 'undefined' ? autoHide : true;
            render().slideDown();
            if(autoHide) fade(_duration, _alert);
            return _alert;
        };

        if(instantShow) this.show();
    };

    $(document).ajaxComplete(function (event, XMLHttpRequest) {
        try {
            var res = $.parseJSON(XMLHttpRequest.responseText);
            if (res !== undefined && res.notifications !== undefined) {
                res.notifications.forEach(function (notification) {
                    new Argu.Alert(notification.message, notification.type, true);
                });
            }
        } catch(e) {}
    });

    $(document).ready(function() {
        $(".alert").slideDown(function() {fade(3000, $(".alert"));});
    });
})();