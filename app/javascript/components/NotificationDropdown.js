import React from 'react';
import ReactTransitionGroup from 'react-addons-transition-group';
import OnClickOutside from 'react-onclickoutside';

import DropdownContent from './DropdownContent';
import HyperDropdownMixin from './mixins/HyperDropdownMixin';
import notificationStore, { NotificationActions } from './stores/notification_store';
import NotificationTrigger from './NotificationTrigger';

export const NotificationDropdown = React.createClass({
    propTypes: {
        dropdownClass: React.PropTypes.string
    },

    mixins: [
        HyperDropdownMixin,
        OnClickOutside
    ],

    getDefaultProps () {
        return {
            dropdownClass: ''
        };
    },

    handleMouseEnterFetch () {
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

        return (<div tabIndex="-1"
                     className={dropdownClass}
                     onMouseEnter={this.handleMouseEnterFetch}
                     onMouseLeave={this.onMouseLeave} >
            <NotificationTrigger handleClick={this.handleClick} handleTap={this.handleTap} className='navbar-item' {...this.props} />
            <div className="reference-elem" style={{ visibility: 'hidden', overflow: 'hidden', 'pointerEvents': 'none', position: 'absolute' }}>{dropdownContent}</div>
            <ReactTransitionGroup transitionName="dropdown" transitionAppear={true} component="div">
                {openState && dropdownContent}
            </ReactTransitionGroup>
        </div>);
    }
});

export default NotificationDropdown;
