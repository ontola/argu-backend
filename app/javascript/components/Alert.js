/* globals $ */

export const ALERT_FADE_TIMEOUT = 2000;
export const ALERT_QUICKFADE_TIMEOUT = 1000;

export default class Alert {
    constructor (message, messageType, instantShow, prependSelector) {
        this.message = typeof message !== 'undefined' ? message : '';
        this.messageType = typeof messageType !== 'undefined' ? messageType : 'success';
        this.instantShow = typeof instantShow !== 'undefined' ? instantShow : false;
        this.prependSelector = typeof prependSelector !== 'undefined' ? prependSelector : '.alert-wrapper';

        this._alert = undefined;
        this._duration = 4000;

        if (instantShow) {
            this.show();
        }
    }

    fade () {
        let timeoutHandle = window.setTimeout(this.fadeNow, this._duration, this._alert);

        this._alert[0].addEventListener('mouseover', () => {
            window.clearTimeout(timeoutHandle);
        });

        this._alert[0].addEventListener('mouseout', () => {
            timeoutHandle = window.setTimeout(this.fadeNow, ALERT_QUICKFADE_TIMEOUT, this._alert)
        });
    }

    fadeNow (a) {
        a.addClass('alert-hidden');
        window.setTimeout(elem => {
            elem.remove();
        }, ALERT_FADE_TIMEOUT, a);
    }

    hide () {
        this.fade();
    }

    render () {
        (this._alert = $(`<div class='alert-container'><div class='alert alert-${this.messageType}'><div class='alert-close'><span class='fa fa-close'></span></div>${this.message}</div></div>`));
        $(this.prependSelector).prepend(this._alert);
        return this._alert;
    }

    show (duration, autoHide) {
        this._duration = typeof this.duration !== 'undefined' ? duration : this._duration;
        autoHide = typeof autoHide !== 'undefined' ? autoHide : true;
        this.render().slideDown();
        if (autoHide) {
            this.fade();
        }
        this._alert
            .on('click', '.alert-close', () => {
                this.fadeNow(this._alert);
            });
        return this._alert;
    }
}
