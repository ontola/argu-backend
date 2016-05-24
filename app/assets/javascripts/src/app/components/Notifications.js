/* globals fetch, NotificationActions */
import React from 'react';
import ReactDOM from 'react-dom';
import ReactTransitionGroup from 'react-addons-transition-group';
import OnClickOutside from 'react-onclickoutside';
import { image } from '../lib/helpers';
import { safeCredentials, statusSuccess, json } from '../lib/helpers';
import notificationStore from '../stores/notification_store';
import HyperDropdownMixin from '../mixins/HyperDropdownMixin';
import { DropdownContent } from './Dropdown';
window.notification_hyper_mixin = HyperDropdownMixin;

export const ScrollLockMixin = {
    cancelScrollEvent (e) {
        e.stopImmediatePropagation();
        e.preventDefault();
        e.returnValue = false;
        return false;
    },

    addScrollEventListener (elem, handler) {
        elem.addEventListener('wheel', handler, false);
    },

    removeScrollEventListener (elem, handler) {
        elem.removeEventListener('wheel', handler, false);
    },

    scrollLock (elem) {
        elem = elem || ReactDOM.findDOMNode(this);
        this.scrollElem = elem;
        ScrollLockMixin.addScrollEventListener(elem, this.onScrollHandler);
    },

    scrollRelease (elem) {
        elem = elem || this.scrollElem;
        ScrollLockMixin.removeScrollEventListener(elem, this.onScrollHandler);
    },

    onScrollHandler (e) {
        const elem = this.scrollElem;
        const scrollTop = elem.scrollTop;
        const scrollHeight = elem.scrollHeight;
        const height = elem.clientHeight;
        const wheelDelta = e.deltaY;
        const isDeltaPositive = wheelDelta > 0;

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

    propTypes: {
        dropdownClass: React.PropTypes.string
    },

    getDefaultProps () {
        return {
            dropdownClass: ''
        };
    },

    onMouseEnterFetch () {
        if (!this.state.opened) {
            NotificationActions.fetchNew();
        }
        NotificationActions.fetchNew();
        this.onMouseEnter();
    },

    render () {
        const { openState, renderLeft } = this.state;
        const dropdownClass = `dropdown ${(openState ? 'dropdown-active' : '')} ${this.props.dropdownClass}`;

        const adaptedProps = this.props;
        if (typeof notificationStore.state.notifications.notifications !== 'undefined') {
            adaptedProps.sections[0].notifications = notificationStore.state.notifications.notifications;
        }
        const dropdownContent = <DropdownContent renderLeft={renderLeft}
                                                 close={this.close}
                                                 notifications={notificationStore.state.notifications.notifications}
                                                 {...adaptedProps}
                                                 key='required' />;

        return (<div tabIndex="1"
                     className={dropdownClass}
                     onMouseEnter={this.onMouseEnterFetch}
                     onMouseLeave={this.onMouseLeave} >
            <NotificationTrigger handleClick={this.handleClick} handleTap={this.handleTap} className='navbar-item' {...this.props} />
            <div className="reference-elem" style={{ visibility: 'hidden', overflow: 'hidden', 'pointerEvents': 'none', position: 'absolute' }}>{dropdownContent}</div>
            <ReactTransitionGroup transitionName="dropdown" transitionAppear={true} component="div">
                {openState && dropdownContent}
            </ReactTransitionGroup>
        </div>);
    }
});
window.NotificationDropdown = NotificationDropdown;

export const NotificationTrigger = React.createClass({
    propTypes: {
        handleClick: React.PropTypes.func,
        handleTap: React.PropTypes.func,
        sections: React.PropTypes.array
    },

    getInitialState () {
        return {
            unread: this.props.sections[0].unread
        };
    },

    onNotificationChange (data) {
        if (typeof data.unread !== 'undefined') {
            this.setState({ unread: data.unread });
        }
    },

    componentDidMount () {
        this.unsubscribe = notificationStore.listen(this.onNotificationChange);
    },

    componentWillUnmount () {
        this.unsubscribe();
    },

    render () {
        const label = this.state.unread > 0 ? <span className='notification-counter'>{this.state.unread}</span> : null;

        return (<div className="dropdown-trigger navbar-item"
                     rel="nofollow"
                     onClick={this.props.handleClick}
                     onTouchEnd={this.props.handleTap}>
            {image({ fa: this.state.unread > 0 ? 'fa-bell' : 'fa-bell' })}
            {label}
        </div>);
    }
});
window.NotificationTrigger = NotificationTrigger;

export const Notifications = React.createClass({
    mixins: [ScrollLockMixin],

    propTypes: {
        done: React.PropTypes.func
    },

    getInitialState () {
        return this.props;
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

    componentDidMount () {
        NotificationActions.notificationUpdate(this.props);
        this.unsubscribe = notificationStore.listen(this.onNotificationChange);
        this.scrollLock(ReactDOM.findDOMNode(this).parentElement);
    },

    componentWillUnmount () {
        this.unsubscribe();
        this.scrollRelease();
    },

    render () {
        const notifications = this
            .state
            .notifications
            .toArray()
            .sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
            .map((item, i) => <NotificationItem key={i} read={item.read} done={this.props.done} {...item} />);

        const loadMore = <li className="notification-btn">
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
    propTypes: {
        created_at: React.PropTypes.string,
        creator: React.PropTypes.shape({
            avatar: React.PropTypes.object
        }),
        data: React.PropTypes.shape({
            remote: React.PropTypes.string,
            method: React.PropTypes.string,
            'turbolinks': React.PropTypes.string,
            type: React.PropTypes.string
        }),
        done: React.PropTypes.func,
        fa: React.PropTypes.string,
        id: React.PropTypes.number,
        image: React.PropTypes.object,
        read: React.PropTypes.bool,
        title: React.PropTypes.string,
        type: React.PropTypes.string,
        url: React.PropTypes.string
    },

    getInitialState () {
        return {};
    },

    handleClick (e) {
        e.stopPropagation();
        fetch(`/n/${this.props.id}.json`, safeCredentials({
            method: 'PUT'
        })).then(statusSuccess)
           .then(json)
           .then(data => {
               NotificationActions.notificationUpdate(data.notifications);
           }).catch(err => {
               throw err;
           });
        this.props.done();
    },

    render () {
        let method, remote, turbolinks;
        const className = [this.props.type, this.props.read ? 'read' : 'unread'].join(' ');
        if (this.props.data) {
            method = this.props.data.method;
            remote = this.props.data.remote;
            turbolinks = this.props.data['turbolinks'];
        }

        return (<li className={`notification-item ${className}`}>
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
