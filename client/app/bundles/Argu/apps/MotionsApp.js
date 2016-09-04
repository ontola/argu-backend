import React from 'react';
import { Provider } from 'react-redux';
import ReactOnRails from 'react-on-rails';
import MotionsContainer from 'containers/MotionsContainer';

const NavbarApp = props => (
  <Provider store={ReactOnRails.getStore('arguStore')}>
    <MotionsContainer {...props} />
  </Provider>
);

export default NavbarApp;
