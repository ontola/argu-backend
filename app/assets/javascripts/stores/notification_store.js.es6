window.NotificationActions = Reflux.createActions({
    "notificationUpdate": {},
    "markAllAsRead": {asyncResult: true},
    "fetchNextPage": {asyncResult: true},
    "checkForNew": {asyncResult: true},
    "fetchNew": {asyncResult: true}
});

window.notificationStore = Reflux.createStore({
    state: {
        notifications: {
            unread: 0,
            notificationCount: 0,
            lastNotification: new Date(null),
            oldestNotification: new Date(null),
            notifications: new OrderedMap()
        }
    },

    init: function() {
        // Register statusUpdate action
        this.listenTo(NotificationActions.notificationUpdate, this.output);
        this.listenTo(NotificationActions.markAllAsRead, this.onMarkAllAsRead);
        this.listenTo(NotificationActions.fetchNextPage, this.fetchNextPage);
        this.listenTo(NotificationActions.checkForNew, this.checkForNew);
        this.listenTo(NotificationActions.fetchNew, this.fetchNew);

        Promise.resolve()
            .then(NotificationActions.checkForNew)
            .then(NotificationActions.fetchNew)
    },

    fetchNextPage: function () {
        "use strict";
        return fetch(`/n.json?from_time=${this.state.notifications.oldestNotification.toISOString()}`, _safeCredentials())
            .then(function (response) {
                if (response.status == 200) {
                    response.json().then(function (data) {
                        NotificationActions.notificationUpdate(data.notifications);
                        NotificationActions.fetchNextPage.completed({
                            moreAvailable: data.notifications.notifications.length == 10
                        });
                    });
                } else if (response.status == 201) {
                    NotificationActions.fetchNextPage.completed({
                        moreAvailable: false
                    });
                }
            }).catch(NotificationActions.fetchNextPage.failed);
    },

    checkForNew: function () {
        "use strict";
        return fetch('//localhost:5000/n', _userIdentityToken({method: 'post', headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
        }}))
            .then(statusSuccess)
            .then(json)
            .then((response) => {
                return NotificationActions.checkForNew.completed(parseInt(response.notificationCount) > this.state.notifications.notificationCount ? response.notificationCount : false);
            })
    },

    fetchNew: function (notificationCount) {
        "use strict";
        if (notificationCount) {
            return fetch(`/n.json?lastNotification=${this.state.notifications.lastNotification.toISOString()}`, _safeCredentials())
                .then(statusSuccess)
                .then(json)
                .then(function (data) {
                    if (typeof(data) !== "undefined") {
                        data.notifications.notificationCount = notificationCount;
                        NotificationActions.notificationUpdate(data.notifications);
                    }
                    return NotificationActions.fetchNew.completed();
                }).catch(NotificationActions.fetchNew.failed);
        } else {
            return NotificationActions.fetchNew.completed();
        }
    },

    onMarkAllAsRead: function () {
        "use strict";
        fetch("/n/read.json", _safeCredentials({
            method: 'PATCH'
        })).then(statusSuccess)
           .then(json)
           .then(function (data) {
               NotificationActions.notificationUpdate(data.notifications);
           }).catch(NotificationActions.markAllAsRead.failed);
    },

    // Callback
    output: function(notifications) {
        "use strict";
        if (notifications) {
            if (notifications.lastNotification) {
                if (this.state.notifications.lastNotification && Date.parse(notifications.lastNotification) > this.state.notifications.lastNotification && notifications.notifications[0].read == false) {
                    document.getElementById('notificationSound').play();
                }
                this.state.notifications.notifications.merge('created_at', notifications.notifications);
                this.setLastNotification(notifications.lastNotification);
                this.state.notifications.unread = notifications.unread;
                this.state.notifications.oldestNotification = new Date(this.state.notifications.notifications.get(this.state.notifications.notifications.length - 1).created_at);
                this.state.notifications.notificationCount = notifications.notificationCount;
                // Pass on to listeners
                this.trigger(this.state.notifications);
            }
        }
    },

    setLastNotification: function (date) {
        "use strict";
        date = new Date(date);
        if (date > this.state.notifications.lastNotification) {
            this.state.notifications.lastNotification = date;
            window.lastNotification = date;
        }
    }

});
