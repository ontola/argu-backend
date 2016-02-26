/* globals NotificationActions */
import React from 'react';
import ReactDOM from 'react-dom';
import ReactTransitionGroup from 'react-addons-transition-group';
import OnClickOutside from 'react-onclickoutside';
import { image } from '../lib/helpers';
import { safeCredentials, statusSuccess, json } from '../lib/helpers';
import notificationStore from '../stores/notification_store';
import HyperDropdownMixin from '../mixins/HyperDropdownMixin';
window.notification_hyper_mixin = HyperDropdownMixin;

export const ScrollLockMixin = {
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
        elem = elem || ReactDOM.findDOMNode(this);
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
window.ScrollLockMixin = ScrollLockMixin;

export const NotificationDropdown = React.createClass({
    mixins: [
        HyperDropdownMixin,
        OnClickOutside
    ],

    onMouseEnterFetch: function () {
        if (!this.state.opened) {
            NotificationActions.fetchNew();
        }
        NotificationActions.fetchNew();
        this.onMouseEnter();
    },

    render: function () {
        const { openState, renderLeft } = this.state;
        const dropdownClass = `dropdown ${(openState ? 'dropdown-active' : '')} ${this.props.dropdownClass || ''}`;

        let adaptedProps = this.props;
        if (typeof notificationStore.state.notifications.notifications !== 'undefined') {
            adaptedProps.sections[0].notifications = notificationStore.state.notifications.notifications;
        }
        let dropdownContent = <DropdownContent renderLeft={renderLeft}
                                               close={this.close}
                                               notifications={notificationStore.state.notifications.notifications}
                                               {...adaptedProps}
                                               key='required' />;

        return (<div tabIndex="1"
                    className={dropdownClass}
                    onMouseEnter={this.onMouseEnterFetch}
                    onMouseLeave={this.onMouseLeave} >
            <NotificationTrigger handleClick={this.handleClick} handleTap={this.handleTap} className='navbar-item' {...this.props} />
            <div className="reference-elem" style={{visibility: 'hidden', overflow: 'hidden', 'pointerEvents': 'none', position: 'absolute'}}>{dropdownContent}</div>
            <ReactTransitionGroup transitionName="dropdown" transitionAppear={true} component="div">
                {openState && dropdownContent}
            </ReactTransitionGroup>
        </div>);
    }
});
window.NotificationDropdown = NotificationDropdown;

export const NotificationTrigger = React.createClass({
    getInitialState: function () {
        return {
            unread: this.props.sections[0].unread
        };
    },

    onNotificationChange: function (data) {
        if (typeof data.unread !== 'undefined') {
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
        var label = this.state.unread > 0 ? <span className='notification-counter'>{this.state.unread}</span> : null;

        return (<div className="dropdown-trigger navbar-item" rel="nofollow" onClick={this.props.handleClick} onTouchEnd={this.props.handleTap}>
            {image({fa: this.state.unread > 0 ? 'fa-bell' : 'fa-bell'})}
            {label}
        </div>);
    }
});
window.NotificationTrigger = NotificationTrigger;

export const Notifications = React.createClass({
    mixins: [ScrollLockMixin],

    getInitialState: function () {
        return this.props;
    },

    markAsRead: function () {
        NotificationActions.markAllAsRead();
    },

    onNotificationChange: function (notifications) {
        if (typeof notifications.unread !== 'undefined') {
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
                if (typeof data !== 'undefined') {
                    this.setState({loadMore: data.moreAvailable});
                }
            });
    },

    componentDidMount: function () {
        NotificationActions.notificationUpdate(this.props);
        this.unsubscribe = notificationStore.listen(this.onNotificationChange);
        this.scrollLock(ReactDOM.findDOMNode(this).parentElement);
    },

    componentWillUnmount: function () {
        this.unsubscribe();
        this.scrollRelease();
    },

    render: function () {
        var notifications = this.props.notifications.map((item, i) => {
            return <NotificationItem key={i} read={item.read} done={this.props.done} {...item} />
        });

        var loadMore = <li className="notification-btn">
                <a href='#' onMouseDownCapture={this.loadMore} data-turbolinks="false">
                    <span className="fa fa-arrow-down"></span>
                    <span className='icon-left'>{this.state.loadMore ? 'Load more...' : 'No more notifications'}</span>
                </a>
            </li>;

        return (<ul className="notifications">
            <li className="notification-btn">
                <a href="#" onClick={this.markAsRead}>
                    <span className="fa fa-check"></span>
                    <span className="icon-left">Mark all as read</span>
                </a>
            </li>
            {notifications}
            {loadMore}
        </ul>);
    }
});
window.Notifications = Notifications;

export const NotificationItem = React.createClass({
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
           }).catch((e) => {
               throw e;
           });
        this.props.done();
    },

    render: function () {
        var method, remote, turbolinks,
            className = [this.props.type, this.props.read ? 'read' : 'unread'].join(' ');
        if (this.props.data) {
            method = this.props.data.method;
            remote = this.props.data.remote;
            turbolinks = this.props.data['turbolinks'];
        }

        return (<li className={'notification-item ' + className}>
            <a href={this.props.url} data-remote={remote} data-method={method} onClick={this.handleClick} data-turbolinks={turbolinks}>
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
