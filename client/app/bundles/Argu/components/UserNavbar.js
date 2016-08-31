import React, { Component, PropTypes } from 'react';
import NavbarWrapper from './NavbarWrapper';
import HyperDropdown from './HyperDropdown';

const propTypes = {
  forumSelector: PropTypes.object,
  profileDropdown: PropTypes.object,
  notificationDropdown: PropTypes.object,
  infoDropdown: PropTypes.object,
};

class UserNavbar extends Component {
  childrenLeft() {
    const { forumSelector } = this.props;
    return [
      <HyperDropdown {...forumSelector} />,
    ];
  }

  childrenRight() {
    const { profileDropdown, notificationDropdown, infoDropdown } = this.props;
    return [
      <HyperDropdown {...profileDropdown} />,
      <HyperDropdown {...notificationDropdown} />,
      <HyperDropdown {...infoDropdown} />,
    ];
  }

  render() {
    return (
      <NavbarWrapper
        contentLeft={this.childrenLeft()}
        contentRight={this.childrenRight()}
      />
    );
  }
}

UserNavbar.propTypes = propTypes;

export default UserNavbar;
