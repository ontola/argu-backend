import React, { Component, PropTypes } from 'react';
import { connect } from 'react-redux';
import { image } from '../lib/helpers';

const propTypes = {
  handleClick: React.PropTypes.func,
  handleTap: React.PropTypes.func,
  unreadCount: PropTypes.number,
};

class NotificationTrigger extends Component {
  label() {
    const { unreadCount } = this.props;
    return unreadCount > 0
            ? <span className="notification-counter">{unreadCount}</span>
            : null;
  }

  render() {
    const { handleClick, handleTap } = this.props;

    return (
      <div
        className="dropdown-trigger navbar-item"
        rel="nofollow"
        onClick={handleClick}
        onTouchEnd={handleTap}
      >
        {image({ fa: 'fa-bell' })}
        {this.label()}
      </div>
    );
  }
}

NotificationTrigger.propTypes = propTypes;


function mapStateToProps(state) {
  return {
    unreadCount: state.notifications.unreadCount,
  };
}

export default connect(mapStateToProps)(NotificationTrigger);
