/* globals $ */

export default function Alert (message, messageType, instantShow, prependSelector) {
    var _alert = undefined,
        _duration = 4000;
    message = typeof message !== 'undefined' ? message : '';
    messageType = typeof messageType !== 'undefined' ? messageType : 'success';
    instantShow = typeof instantShow !== 'undefined' ? instantShow : false;
    prependSelector = typeof prependSelector !== 'undefined' ? prependSelector : '.alert-wrapper';

    var render = function () {
        (_alert = $(`<div class='alert-container'><pre class='alert alert-${messageType}'>${message}</pre></div>`));
        $(prependSelector).prepend(_alert);
        return _alert;
    };

    this.hide = function () {
        this.fade(_duration, _alert);
    };

    this.fade = function (duration, _alert) {
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

    this.show = function (duration, autoHide) {
        _duration = typeof duration !== 'undefined' ? duration : _duration;
        autoHide = typeof autoHide !== 'undefined' ? autoHide : true;
        render().slideDown();
        if (autoHide) {
            this.fade(_duration, _alert);
        }
        return _alert;
    };

    if (instantShow) {
        this.show();
    }
}
