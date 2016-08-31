import React from 'react';
import { Provider } from 'react-redux';
import ReactOnRails from 'react-on-rails';
import SmallVoteContainer from '../containers/SmallVoteContainer';

const SmallVoteApp = props => (
  <Provider store={ReactOnRails.getStore('arguStore')}>
    <SmallVoteContainer {...props} />
  </Provider>
);

export default SmallVoteApp;
