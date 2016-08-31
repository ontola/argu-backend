import React, { Component, PropTypes } from 'react';

const propTypes = {
  contentLeft: PropTypes.arrayOf(PropTypes.node),
  contentRight: PropTypes.arrayOf(PropTypes.node),
};

class NavbarWrapper extends Component {
  wrapInListItems(content, keyBase) {
    return content && content
        .map(
          (item, i) =>
            <li key={`${keyBase}.${i}`}>
              {item}
            </li>
        );
  }

  render() {
    const {
      contentLeft,
      contentRight,
    } = this.props;

    return (
      <nav id="navbar" className="navbar" role="navigation">
        <div className="nav-container">
          <div className="navbar-logo">
            <a href="/">
              <img src="/assets/logo-white.svg" alt="Argu Logo" />
            </a>
          </div>
          <ul className="navbar-links">
            <li>
              <a href="/" className="navbar-item">
                <span className="fa fa-home" />
              </a>
            </li>
            {this.wrapInListItems(contentLeft, 'navbar-links-right')}
          </ul>
          <ul className="navbar-links navbar-links-right">
            {this.wrapInListItems(contentRight, 'navbar-links-left')}
          </ul>
        </div>
      </nav>
    );
  }
}

NavbarWrapper.propTypes = propTypes;

export default NavbarWrapper;
