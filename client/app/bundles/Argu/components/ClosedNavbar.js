import React, { Component } from 'react';
import NavbarWrapper from './NavbarWrapper';

class ClosedNavbar extends Component {
  childrenRight() {
    return [
      <a href="/users/sign_out" id="sign_in" className="navbar-item center">
        <span className="fa fa-sign" />
        <span className="icon-left dont-hide">Sign out</span>
      </a>,
    ];
  }

  render() {
    return (
      <NavbarWrapper contentRight={this.childrenRight()} />
    );
  }
}

export default ClosedNavbar;
