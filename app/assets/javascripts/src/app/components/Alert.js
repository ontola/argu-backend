/* globals $ */

const ALERT_FADE_TIMEOUT = 2000;
const ALERT_QUICKFADE_TIMEOUT = 1000;

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
        const fadeNow = function(a) {
            a.addClass('alert-hidden');
            window.setTimeout(elem => {
                elem.remove();
            }, ALERT_FADE_TIMEOUT, a);
        };

        let timeoutHandle = window.setTimeout(fadeNow, this._duration, this._alert);

        this._alert[0].addEventListener('mouseover', () => {
            window.clearTimeout(timeoutHandle);
        });

        this._alert[0].addEventListener('mouseout', () => {
            timeoutHandle = window.setTimeout(fadeNow, ALERT_QUICKFADE_TIMEOUT, this._alert)
        });
    }

    hide () {
        this.fade();
    }

    render () {
        (this._alert = $(`<div class='alert-container'><pre class='alert alert-${this.messageType}'>${this.message}</pre></div>`));
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
        return this._alert;
    }
}
