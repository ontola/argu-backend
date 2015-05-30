window.NotificationActions = Reflux.createActions({
    "notificationUpdate": {},
    "markAllAsRead": {asyncResult: true}
});

window.notificationStore = Reflux.createStore({
    init: function() {
        // Register statusUpdate action
        this.listenTo(NotificationActions.notificationUpdate, this.output);
        this.listenTo(NotificationActions.markAllAsRead, this.onMarkAllAsRead);
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
        if (notifications) {
            if (notifications.lastNotification) {
                if (Date.parse(this.lastNotification) && Date.parse(notifications.lastNotification) > Date.parse(this.lastNotification) && notifications.notifications[0].read == false) {
                    document.getElementById('notificationSound').play();
                }
                this.lastNotification = notifications.lastNotification;
                window.lastNotification = this.lastNotification;
            }
            // Pass on to listeners
            this.trigger(notifications);
        }
    }

});
