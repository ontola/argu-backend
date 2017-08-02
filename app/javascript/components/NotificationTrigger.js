import React from 'react';

import notificationStore from './stores/notification_store';
import { image } from './lib/helpers';

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

    componentDidMount () {
        this.unsubscribe = notificationStore.listen(this.onNotificationChange);
    },

    componentWillUnmount () {
        this.unsubscribe();
    },

    onNotificationChange (data) {
        if (typeof data.unread !== 'undefined') {
            this.setState({ unread: data.unread });
        }
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

export default NotificationTrigger;
