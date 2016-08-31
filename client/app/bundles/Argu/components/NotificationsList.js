/* globals I18n */
import React, { Component, PropTypes } from 'react';
import NotificationItem from './NotificationItem';

const propTypes = {
  done: PropTypes.func,
  indexNotifications: PropTypes.func,
  loadMore: PropTypes.bool,
  nextPage: PropTypes.number,
  notifications: PropTypes.array,
};

class NotificationsList extends Component {
  handleClick = () => {
    this.props.indexNotifications(this.props.nextPage);
  };

  render() {
    const { done, loadMore, notifications } = this.props;

    const notificationsItems = notifications
      .map((item, i) => <NotificationItem key={i} read={item.read} done={done} {...item} />);

    const loadMoreButton = (
      <li className="notification-btn">
        <a
          href="#"
          onMouseDownCapture={this.handleClick}
          data-turbolinks="false"
        >
          <span className="fa fa-arrow-down"></span>
          <span className="icon-left">
            {loadMore ? I18n.t('ui.load_more') : I18n.t('no_more_type')}
          </span>
        </a>
      </li>
    );

    return (
      <ul className="notifications">
        <li className="notification-btn">
          <a href="#">
            <span className="fa fa-check"></span>
            <span className="icon-left">{I18n.t('notifications.mark_all_as_read')}</span>
          </a>
        </li>
        {notificationsItems}
        {loadMoreButton}
      </ul>
    );
  }
}

NotificationsList.propTypes = propTypes;

export default NotificationsList;
