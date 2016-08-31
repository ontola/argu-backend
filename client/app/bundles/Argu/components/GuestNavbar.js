/* globals I18n */
import React, { Component, PropTypes } from 'react';
import NavbarWrapper from './NavbarWrapper';
import HyperDropdown from './HyperDropdown';

const propTypes = {
  forumSelector: PropTypes.object,
  infoDropdown: PropTypes.object,
};

class GuestNavbar extends Component {
  childrenLeft() {
    const { forumSelector } = this.props;
    return [
      <HyperDropdown {...forumSelector} />,
    ];
  }

  childrenRight() {
    const { infoDropdown } = this.props;
    return [
      <HyperDropdown {...infoDropdown} />,
      <a href="/users/sign_in" id="sign_in" className="navbar-item center">
        <span className="fa fa-sign-in" />
        <span className="icon-left dont-hide">{I18n.t('sign_in')}</span>
      </a>,
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

GuestNavbar.propTypes = propTypes;

export default GuestNavbar;
