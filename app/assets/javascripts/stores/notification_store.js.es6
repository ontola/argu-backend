window.NotificationActions = Reflux.createActions({
    "notificationUpdate": {},
    "markAllAsRead": {asyncResult: true},
    "fetchNextPage": {asyncResult: true},
    "checkForNew": {asyncResult: true}
});

window.notificationStore = Reflux.createStore({
    state: {
        notifications: {
            unread: 0,
            lastNotification: new Date(null),
            oldestNotification: new Date(null),
            notifications: []
        }
    },

    init: function() {
        // Register statusUpdate action
        this.listenTo(NotificationActions.notificationUpdate, this.output);
        this.listenTo(NotificationActions.markAllAsRead, this.onMarkAllAsRead);
        this.listenTo(NotificationActions.fetchNextPage, this.fetchNextPage);
        this.listenTo(NotificationActions.checkForNew, this.checkForNew);

        this.checkForNew();
    },

    fetchNextPage: function () {
        "use strict";
        $.ajax({
            url: `/n.json?from_time=${this.state.notifications.oldestNotification.toISOString()}`
        }).done(function (data) {
            NotificationActions.notificationUpdate(data.notifications);
            NotificationActions.fetchNextPage.completed({
                moreAvailable: data.notifications.notifications.length == 10
            });
        }).fail(NotificationActions.markAllAsRead.failed);
    },

    checkForNew: function () {
        "use strict";
        $.ajax({
            url: `/n.json?lastNotification=${this.state.notifications.lastNotification.toISOString()}`
        }).done(function (data) {
            if (typeof(data) !== "undefined") {
                NotificationActions.notificationUpdate(data.notifications);
                NotificationActions.checkForNew.completed();
            }
        }).fail(NotificationActions.markAllAsRead.failed);
    },

    onMarkAllAsRead: function () {
        "use strict";
        $.ajax({
            url: "/n/read.json",
            method: "PATCH"
        }).done(function (data) {
            NotificationActions.notificationUpdate(data.notifications);
        }).fail(NotificationActions.markAllAsRead.failed);
    },

    // Callback
    output: function(notifications) {
        "use strict";
        if (notifications) {
            if (notifications.lastNotification) {
                if (this.state.notifications.lastNotification && Date.parse(notifications.lastNotification) > this.state.notifications.lastNotification && notifications.notifications[0].read == false) {
                    document.getElementById('notificationSound').play();
                }
                if (notifications.from_time == null) {
                    this.state.notifications.notifications.push(...notifications.notifications);
                } else {
                    this.state.notifications.notifications.push(...notifications.notifications.reverse());
                }
                this.setLastNotification(notifications.lastNotification);
                this.state.notifications.unread = notifications.unread;
                this.state.notifications.oldestNotification = new Date(this.state.notifications.notifications[this.state.notifications.notifications.length - 1].created_at);
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
