import React, { Component, PropTypes } from 'react';
import { connect } from 'react-redux';

import ClosedNavbarContainer from './ClosedNavbarContainer';
import GuestNavbarContainer from './GuestNavbarContainer';
import UserNavbarContainer from './UserNavbarContainer';

const propTypes = {
  userState: PropTypes.string.isRequired,
  finishedIntro: PropTypes.bool,
};

class NavbarContainer extends Component {
  component() {
    const { finishedIntro, userState } = this.props;
    if (userState === 'user' && !finishedIntro) {
      return ClosedNavbarContainer;
    } else if (userState === 'user') {
      return UserNavbarContainer;
    }
    return GuestNavbarContainer;
  }

  render() {
    const NavbarComponent = this.component();
    return <NavbarComponent />;
  }
}

NavbarContainer.propTypes = propTypes;

function mapStateToProps(state) {
  const ca = state.getIn(['current-actors', 'items', 'currentactor']);
  return {
    userState: ca.get('userState')
  };
}

export default connect(mapStateToProps)(NavbarContainer);
