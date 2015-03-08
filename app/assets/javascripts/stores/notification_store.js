window.NotificationActions = Reflux.createActions([
    "notificationUpdate"
]);

window.notificationStore = Reflux.createStore({
    init: function() {
        // Register statusUpdate action
        this.listenTo(NotificationActions.notificationUpdate, this.output);
    },

    // Callback
    output: function(notifications) {
        if (notifications.lastNotification) {
            if (Date.parse(this.lastNotification) && Date.parse(notifications.lastNotification) > Date.parse(this.lastNotification) && notifications.notifications[0].read == false) {
                document.getElementById('notificationSound').play();
            }
            this.lastNotification = notifications.lastNotification;
        }
        // Pass on to listeners
        this.trigger(notifications);
    }

});
