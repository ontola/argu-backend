/*global $, Argu*/

Argu.alert = {
    init: function () {
        $(document)
            .on('pjax:end', Argu.alert.fadeAll)
            .ajaxComplete(Argu.alert.handleJSONBody);
        Argu.alert.fadeAll();
    },

    fade: function (duration, _alert) {

        var fadeNow = function(a) {
            a.addClass('alert-hidden');
            window.setTimeout(function(a) {
                a.remove();
            }, 2000, a);
        };

        var timeoutHandle = window.setTimeout(fadeNow, duration, _alert);

        _alert.mouseover(function(){
            window.clearTimeout(timeoutHandle);
        });

        _alert.mouseout(function(){
            timeoutHandle = window.setTimeout(fadeNow, 1000, _alert)
        });
    },

    fadeAll: function () {
        $(".alert").slideDown(function() {Argu.alert.fade(3000, $(".alert"));});
    },

    handleJSONBody: function (event, XMLHttpRequest) {
        try {
            var res = $.parseJSON(XMLHttpRequest.responseText);
            if (res !== undefined && res.notifications !== undefined) {
                res.notifications.forEach(function (notification) {
                    new Argu.Alert(notification.message, notification.type, true);
                });
            }
        } catch(e) {}
    }
};

Argu.Alert = function (message, messageType, instantShow, beforeSelector) {
    "use strict";
    var alert = this,
        _alert = undefined,
        _duration = 400000;
    message        = typeof message        !== 'undefined' ? message : '';
    messageType    = typeof messageType    !== 'undefined' ? messageType : 'success';
    instantShow    = typeof instantShow    !== 'undefined' ? instantShow : false;
    beforeSelector = typeof beforeSelector !== 'undefined' ? beforeSelector : '.alert-before-selector';

    var render = function () {
        (_alert = $("<div class='alert-container'><pre class='alert alert-" + messageType + "'>" + message + "</pre></div>")).insertBefore($(beforeSelector));
        return _alert;
    };

    this.hide = function () {
        Argu.alert.fade(_duration, _alert);
    };

    this.show = function (duration, autoHide) {
        _duration = typeof duration !== 'undefined' ? duration : _duration;
        autoHide = typeof autoHide !== 'undefined' ? autoHide : true;
        render().slideDown();
        if(autoHide) Argu.alert.fade(_duration, _alert);
        return _alert;
    };

    if(instantShow) this.show();
};
