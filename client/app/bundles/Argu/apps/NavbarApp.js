import React from 'react';
import { Provider } from 'react-redux';
import ReactOnRails from 'react-on-rails';
import NavbarContainer from '../containers/NavbarContainer';

const NavbarApp = props => (
  <Provider store={ReactOnRails.getStore('arguStore')}>
    <NavbarContainer {...props} />
  </Provider>
);

export default NavbarApp;
