
const n = {
    refreshing: false,
    lastNotificationCheck: Date.now(),
    timeoutValue: 30000,
    notificationTimeout: null,
    hidden: '', // Set when eventListener is setup

    init: function () {
        "use strict";

        n.resetTimeout();
        document.addEventListener(n.visibilityChange(), n.handleVisibilityChange, false);
        $(document).ajaxComplete(n.handleNotificationHeader());
    },

    handleVisibilityChange: function () {
        if (window.lastNotification != '-1') {
            if (document[n.hidden]) {
                n.timeoutValue = 120000;
                n.resetTimeout();
            } else {
                n.timeoutValue = 30000;
                n.refreshNotifications();
            }
        }
    },

    handleNotificationHeader: function (e, xhr) {
        if (xhr) {
            xhr.getResponseHeader('lastNotification');
            if (xhr.getResponseHeader('lastNotification') == '-1') {
                window.lastNotification = '-1';
                window.clearTimeout(n.notificationTimeout);
            } else {
                window.lastNotification = window.lastNotification == '-1' ? null : window.lastNotification;
                if (Date.parse(xhr.getResponseHeader('lastNotification')) > Date.parse(window.lastNotification)) {
                    n.refreshNotifications();
                } else {
                    n.resetTimeout();
                }
            }
        }
    },

    refreshNotifications: function (force = false) {
        "use strict";
        if (force || window.lastNotification != '-1' && !n.refreshing && (!window.lastNotification || Date.now() - n.lastNotificationCheck >= 15000)) {
            window.clearTimeout(n.notificationTimeout);
            n.refreshing = true;
            n.lastNotificationCheck = Date.now();
            let done = function () {
                n.refreshing = false;
                n.resetTimeout();
                return Promise.resolve();
            };
            Promise.resolve()
                .then(NotificationActions.checkForNew)
                .then(NotificationActions.fetchNew)
                .then(done)
                .catch((e) => {
                    console.log('error', e);
                    Bugsnag.notifyException(e);
                    done();
                });
        } else if (window.lastNotification != '-1' && !n.refreshing) {
            n.resetTimeout();
        }
    },

    resetTimeout: function () {
        window.clearTimeout(n.notificationTimeout);
        n.notificationTimeout = window.setTimeout(n.refreshNotifications, n.timeoutValue);
    },

    visibilityChange: function () {
        "use strict";
        var hidden, visibilityChange;
        if (typeof document.hidden !== "undefined") { // Opera 12.10 and Firefox 18 and later support
            hidden = "hidden";
            visibilityChange = "visibilitychange";
        } else if (typeof document.mozHidden !== "undefined") {
            hidden = "mozHidden";
            visibilityChange = "mozvisibilitychange";
        } else if (typeof document.msHidden !== "undefined") {
            hidden = "msHidden";
            visibilityChange = "msvisibilitychange";
        } else if (typeof document.webkitHidden !== "undefined") {
            hidden = "webkitHidden";
            visibilityChange = "webkitvisibilitychange";
        }

        n.hidden = hidden;
        return visibilityChange;
    }
};

export default n;
