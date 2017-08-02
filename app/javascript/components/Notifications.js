import React from 'react';
import ReactDOM from 'react-dom';

import ScrollLockMixin from './ScrollLockMixin';
import notificationStore, { NotificationActions } from './stores/notification_store';
import NotificationItem from './NotificationItem';

export const Notifications = React.createClass({
    propTypes: {
        done: React.PropTypes.func
    },

    mixins: [ScrollLockMixin],

    getInitialState () {
        return this.props;
    },

    componentDidMount () {
        NotificationActions.notificationUpdate(this.props);
        this.unsubscribe = notificationStore.listen(this.onNotificationChange);
        this.scrollLock(ReactDOM.findDOMNode(this).parentElement);
    },

    componentWillUnmount () {
        this.unsubscribe();
        this.scrollRelease();
    },

    markAsRead () {
        NotificationActions.markAllAsRead();
    },

    onNotificationChange (notifications) {
        if (typeof notifications.unread !== 'undefined') {
            this.setState({
                unread: notifications.unread || this.state.unread,
                lastNotification: notifications.lastNotification || this.state.lastNotification,
                notifications: notifications.notifications
            });
        }
    },

    loadMore () {
        NotificationActions
          .fetchNextPage()
          .then(data => {
              if (typeof data !== 'undefined') {
                  this.setState({ loadMore: data.moreAvailable });
              }
          });
    },

    render () {
        const notifications = this
          .state
          .notifications
          .toArray()
          .sort((a, b) => {
              if (a.permanent === b.permanent) {
                  return new Date(b.created_at) - new Date(a.created_at);
              } else {
                  return a.permanent ? -1 : 1;
              }
          }).map((item, i) => {
              return <NotificationItem key={i} read={item.read} done={this.props.done} {...item} />
          });

        const loadMore = <li className="notification-btn">
            <a href='#' onMouseDownCapture={this.loadMore} data-turbolinks="false">
                <span className="fa fa-arrow-down" />
                <span className='icon-left'>{this.state.loadMore ? 'Load more...' : 'No more notifications'}</span>
            </a>
        </li>;

        return (<ul className="notifications">
            <li className="notification-btn">
                <a href="#" onClick={this.markAsRead}>
                    <span className="fa fa-check" />
                    <span className="icon-left">Mark all as read</span>
                </a>
            </li>
            {notifications}
            {loadMore}
        </ul>);
    }
});

export default Notifications;
