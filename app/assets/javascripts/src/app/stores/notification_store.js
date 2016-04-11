/* globals NotificationActions */
import { userIdentityToken, statusSuccess, json, safeCredentials } from '../lib/helpers';
import Reflux from 'reflux';
import { OrderedMap } from 'immutable';

const NOTIFICATION_PAGE_LENGTH = 10;

window.NotificationActions = Reflux.createActions({
    'notificationUpdate': {},
    'markAllAsRead': { asyncResult: true },
    'fetchNextPage': { asyncResult: true },
    'checkForNew': { asyncResult: true },
    'fetchNew': { asyncResult: true }
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

    init () {
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

    fetchNextPage () {
        return fetch(`/n.json?from_time=${this.state.notifications.oldestNotification.toISOString()}`, safeCredentials())
            .then(response => {
                if (response.status === 200) {
                    response.json().then(data => {
                        NotificationActions.notificationUpdate(data.notifications);
                        NotificationActions
                            .fetchNextPage
                            .completed({
                                moreAvailable: data.notifications.notifications.length === NOTIFICATION_PAGE_LENGTH
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

    checkForNew () {
        return fetch('//meta.argu.co/n', userIdentityToken({
            method: 'post',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            }
        }))
            .then(statusSuccess)
            .then(json)
            .then(response => {
                return NotificationActions.checkForNew.completed(parseInt(response.notificationCount) > this.state.notifications.notificationCount ? response.notificationCount : false);
            })
    },

    fetchNew (notificationCount) {
        const from = this.state.notifications.lastNotification.toISOString();
        return fetch(`/n.json?lastNotification=${from}`, safeCredentials())
            .then(statusSuccess)
            .then(json)
            .then(data => {
                if (typeof data !== 'undefined') {
                    data.notifications.notificationCount = notificationCount;
                    NotificationActions.notificationUpdate(data.notifications);
                }
                return NotificationActions.fetchNew.completed();
            }).catch(NotificationActions.fetchNew.failed);
    },

    onMarkAllAsRead () {
        fetch('/n/read.json', safeCredentials({
            method: 'PATCH'
        })).then(statusSuccess)
           .then(json)
           .then(data => {
               NotificationActions.notificationUpdate(data.notifications);
           }).catch(NotificationActions.markAllAsRead.failed);
    },

    // Callback
    output (notifications) {
        if (notifications) {
            if (notifications.lastNotification) {
                if (this.state.notifications.lastNotification && Date.parse(notifications.lastNotification) > this.state.notifications.lastNotification && notifications.notifications[0].read === false) {
                    document.getElementById('notificationSound').play();
                }
                this.state.notifications.notifications = this
                    .state
                    .notifications
                    .notifications
                    .withMutations(mutMap => {
                        notifications.notifications.map(n => {
                            mutMap.set(n.id, n);
                        });
                    }).sort((a, b) => {
                        return new Date(b.created_at) - new Date(a.created_at);
                    });
                this.setLastNotification(notifications.lastNotification);
                this.state.notifications.unread = notifications.unread;
                this.state.notifications.oldestNotification = new Date(this.state
                    .notifications
                    .notifications
                    .sort((a, b) => {
                        return new Date(b.created_at) - new Date(a.created_at);
                    })
                    .last()
                    .created_at);
                this.state.notifications.notificationCount = notifications.notificationCount;
                // Pass on to listeners
                this.trigger(this.state.notifications);
            }
        }
    },

    setLastNotification (date) {
        date = new Date(date);
        if (date > this.state.notifications.lastNotification) {
            this.state.notifications.lastNotification = date;
            window.lastNotification = date;
        }
    }

});
window.notificationStore = notificationStore;

export default notificationStore;
