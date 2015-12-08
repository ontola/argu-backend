/* globals NotificationActions */
import { userIdentityToken, statusSuccess, json, safeCredentials } from '../lib/helpers';
import Reflux from 'reflux';
import OrderedMap from '../lib/OrderedMap'


window.NotificationActions = Reflux.createActions({
    'notificationUpdate': {},
    'markAllAsRead': {asyncResult: true},
    'fetchNextPage': {asyncResult: true},
    'checkForNew': {asyncResult: true},
    'fetchNew': {asyncResult: true}
});

const notificationStore = Reflux.createStore({
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

        Promise
            .resolve()
            .then(NotificationActions.checkForNew)
            .then(count => {
                if (count >= 0) {
                    return NotificationActions.fetchNew();
                }
            });
    },

    fetchNextPage: function () {
        return fetch(`/n.json?from_time=${this.state.notifications.oldestNotification.toISOString()}`, safeCredentials())
            .then(function (response) {
                if (response.status === 200) {
                    response.json().then(function (data) {
                        NotificationActions.notificationUpdate(data.notifications);
                        NotificationActions
                            .fetchNextPage
                            .completed({
                                moreAvailable: data.notifications.notifications.length === 10
                            });
                    });
                } else if (response.status === 201) {
                    NotificationActions
                        .fetchNextPage
                        .completed({
                            moreAvailable: false
                        });
                }
            }).catch(NotificationActions.fetchNextPage.failed);
    },

    checkForNew: function () {
        return fetch('//meta.argu.co/n', userIdentityToken({method: 'post', headers: {
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
        let from = this.state.notifications.lastNotification.toISOString();
        return fetch(`/n.json?lastNotification=${from}`, safeCredentials())
            .then(statusSuccess)
            .then(json)
            .then(function (data) {
                if (typeof data !== 'undefined') {
                    data.notifications.notificationCount = notificationCount;
                    NotificationActions.notificationUpdate(data.notifications);
                }
                return NotificationActions.fetchNew.completed();
            }).catch(NotificationActions.fetchNew.failed);
    },

    onMarkAllAsRead: function () {
        fetch('/n/read.json', safeCredentials({
            method: 'PATCH'
        })).then(statusSuccess)
           .then(json)
           .then(function (data) {
               NotificationActions.notificationUpdate(data.notifications);
           }).catch(NotificationActions.markAllAsRead.failed);
    },

    // Callback
    output: function(notifications) {
        if (notifications) {
            if (notifications.lastNotification) {
                if (this.state.notifications.lastNotification && Date.parse(notifications.lastNotification) > this.state.notifications.lastNotification && notifications.notifications[0].read === false) {
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
        date = new Date(date);
        if (date > this.state.notifications.lastNotification) {
            this.state.notifications.lastNotification = date;
            window.lastNotification = date;
        }
    }

});
window.notificationStore = notificationStore;

export default notificationStore;
