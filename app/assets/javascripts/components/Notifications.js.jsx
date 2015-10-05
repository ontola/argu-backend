import React from 'react/react-with-addons';
import { image } from '../lib/helpers';
import { safeCredentials } from '../lib/helpers;

export var ScrollLockMixin = {
    cancelScrollEvent: function (e) {
        e.stopImmediatePropagation();
        e.preventDefault();
        e.returnValue = false;
        return false;
    },

    addScrollEventListener: function (elem, handler) {
        elem.addEventListener('wheel', handler, false);
    },

    removeScrollEventListener: function (elem, handler) {
        elem.removeEventListener('wheel', handler, false);
    },

    scrollLock: function (elem) {
        elem = elem || this.getDOMNode();
        this.scrollElem = elem;
        ScrollLockMixin.addScrollEventListener(elem, this.onScrollHandler);
    },

    scrollRelease: function (elem) {
        elem = elem || this.scrollElem;
        ScrollLockMixin.removeScrollEventListener(elem, this.onScrollHandler);
    },

    onScrollHandler: function (e) {
        var elem = this.scrollElem;
        var scrollTop = elem.scrollTop;
        var scrollHeight = elem.scrollHeight;
        var height = elem.clientHeight;
        var wheelDelta = e.deltaY;
        var isDeltaPositive = wheelDelta > 0;

        if (isDeltaPositive && wheelDelta > scrollHeight - height - scrollTop) {
            elem.scrollTop = scrollHeight;
            return ScrollLockMixin.cancelScrollEvent(e);
        }
        else if (!isDeltaPositive && -wheelDelta > scrollTop) {
            elem.scrollTop = 0;
            return ScrollLockMixin.cancelScrollEvent(e);
        }
    }
};

export var NotificationTrigger = React.createClass({
    getInitialState: function () {
        return {
            unread: this.props.sections[0].unread
        };
    },

    onNotificationChange: function (data) {
        if (typeof(data.unread) != "undefined") {
            this.setState({unread: data.unread});
        }
    },

    componentDidMount: function () {
        this.unsubscribe = notificationStore.listen(this.onNotificationChange);
    },

    componentWillUnmount: function () {
        this.unsubscribe();
    },

    render: function () {
        var triggerClass = "dropdown-trigger " + this.props.trigger.triggerClass;
        var label = this.state.unread > 0 ? <span className='notification-counter'>{this.state.unread}</span> : null;

        return (<div className={triggerClass} rel="nofollow" onClick={this.props.handleClick} onTouchEnd={this.props.handleTap}>
            {image({fa: this.state.unread > 0 ? 'fa-bell' : 'fa-bell'})}
            {label}
        </div>);
    }
});
window.NotificationTrigger = NotificationTrigger;

export var Notifications = React.createClass({
    mixins: [ScrollLockMixin],

    getInitialState: function () {
        return this.props;
    },

    markAsRead: function () {
        NotificationActions.markAllAsRead();
    },

    onNotificationChange: function (notifications) {
        if (typeof(notifications.unread) != "undefined") {
            this.setState({
                unread: notifications.unread || this.state.unread,
                lastNotification: notifications.lastNotification || this.state.lastNotification,
                notifications: notifications.notifications
            });
        }
    },

    loadMore: function () {
        NotificationActions
            .fetchNextPage()
            .then((data) => {
                if (typeof data !== "undefined") {
                    this.setState({loadMore: data.moreAvailable});
                }
            });
    },

    componentDidMount: function () {
        NotificationActions.notificationUpdate(this.props);
        this.unsubscribe = notificationStore.listen(this.onNotificationChange);
        this.scrollLock(this.getDOMNode().parentElement);
        NotificationActions.fetchNew();
    },

    componentWillUnmount: function () {
        this.unsubscribe();
        this.scrollRelease();
    },

    render: function () {
        var notifications = this.state.notifications.map((item) => {
            return <NotificationItem key={item.id} read={item.read} done={this.props.done} {...item} />
        });

        var loadMore = <li>
                <a href='#' onMouseDownCapture={this.loadMore} data-skip-pjax="true">
                    <span className='notification-description'>{this.state.loadMore ? 'Meer' : 'Geen oudere'}</span>
                </a>
            </li>;

        return (<ul className="notifications">
            <p className="notifications-btn-top">
                <span>Notificaties bèta</span>
            </p>
            <p className="notifications-btn-top">
                <a href="#" onClick={this.markAsRead}>
                    <span className="fa fa-check"></span>
                    <span className="icon-left">Markeer alle als gelezen</span>
                </a>
            </p>
            {notifications}
            {loadMore}
        </ul>);
    }
});
window.Notifications = Notifications;

export var NotificationItem = React.createClass({
    getInitialState: function () {
        return {};
    },

    handleClick: function (e) {
        e.stopPropagation();
        fetch(`/n/${this.props.id}.json`, safeCredentials({
            method: 'PUT'
        })).then(statusSuccess)
           .then(json)
           .then((data) => {
                NotificationActions.notificationUpdate(data.notifications);
           }).catch(console.log);
        this.props.done();
    },

    render: function () {
        var method, remote, skipPjax,
            className = [this.props.type, this.props.read ? 'read' : 'unread'].join(' ');
        if (this.props.data) {
            method = this.props.data.method;
            remote = this.props.data.remote;
            skipPjax = this.props.data['skip-pjax'];
        }

        return (<li className={className}>
            <a href={this.props.url} data-remote={remote} data-method={method}  onClick={this.handleClick} data-skip-pjax={skipPjax}>
                <img src={this.props.creator.avatar.url} className="notification-avatar" />
                <span className='notification-description'>{this.props.title}</span>
                <div className='notification-bottom'>
                    <span className={(this.props.image || this.props.fa) ? 'icon-left' : ''}>{this.props.created_at}</span>
                    {image(this.props)}
                </div>
            </a>
        </li>);
    }
});
window.NotificationItem = NotificationItem;
