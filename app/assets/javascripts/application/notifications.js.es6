
Argu.n = {
    refreshing: false,
    lastNotificationCheck: Date.now(),
    timeoutValue: 30000,
    notificationTimeout: null,
    hidden: '', // Set when eventListener is setup

    init: function () {
        "use strict";

        Argu.n.resetTimeout();
        document.addEventListener(Argu.n.visibilityChange(), Argu.n.handleVisibilityChange, false);
        $(document).ajaxComplete(Argu.n.handleNotificationHeader());
    },

    handleVisibilityChange: function () {
        if (window.lastNotification != '-1') {
            if (document[Argu.n.hidden]) {
                Argu.n.timeoutValue = 120000;
                Argu.n.resetTimeout();
            } else {
                Argu.n.timeoutValue = 30000;
                Argu.n.refreshNotifications();
            }
        }
    },

    handleNotificationHeader: function (e, xhr) {
        if (xhr) {
            xhr.getResponseHeader('lastNotification');
            if (xhr.getResponseHeader('lastNotification') == '-1') {
                window.lastNotification = '-1';
                window.clearTimeout(Argu.n.notificationTimeout);
            } else {
                window.lastNotification = window.lastNotification == '-1' ? null : window.lastNotification;
                if (Date.parse(xhr.getResponseHeader('lastNotification')) > Date.parse(window.lastNotification)) {
                    Argu.n.refreshNotifications();
                } else {
                    Argu.n.resetTimeout();
                }
            }
        }
    },

    refreshNotifications: function () {
        "use strict";
        if (window.lastNotification != '-1' && !Argu.n.refreshing && (!window.lastNotification || Date.now() - Argu.n.lastNotificationCheck >= 15000)) {
            window.clearTimeout(Argu.n.notificationTimeout);
            Argu.n.refreshing = true;
            Argu.n.lastNotificationCheck = Date.now();
            NotificationActions.checkForNew().then(function () {
                Argu.n.refreshing = false;
                Argu.n.resetTimeout();
            }, function () {
                console.log('failed');
                Argu.n.refreshing = false;
                Argu.n.resetTimeout();
            });
        } else if (window.lastNotification != '-1' && !Argu.n.refreshing) {
            Argu.n.resetTimeout();
        }
    },

    resetTimeout: function () {
        window.clearTimeout(Argu.n.notificationTimeout);
        Argu.n.notificationTimeout = window.setTimeout(Argu.n.refreshNotifications, Argu.n.timeoutValue);
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

        Argu.n.hidden = hidden;
        return visibilityChange;
    }
};
