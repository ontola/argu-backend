/* globals I18n */
import React, { Component, PropTypes } from 'react';
import NavbarWrapper from './NavbarWrapper';
import HyperDropdown from './HyperDropdown';
import ForumSelectorContainer from '../containers/ForumSelectorContainer';

const propTypes = {
  infoDropdown: PropTypes.object,
};

class GuestNavbar extends Component {
  childrenLeft() {
    return [
      <ForumSelectorContainer />
    ];
  }

  childrenRight() {
    const { infoDropdown } = this.props;
      //<HyperDropdown {...infoDropdown} />,
    return [
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
