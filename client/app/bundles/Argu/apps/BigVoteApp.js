import React from 'react';
import { Provider } from 'react-redux';
import ReactOnRails from 'react-on-rails';
import BigVoteContainer from '../containers/BigVoteContainer';

const BigVoteApp = props => (
  <Provider store={ReactOnRails.getStore('arguStore')}>
    <BigVoteContainer {...props} />
  </Provider>
);

export default BigVoteApp;
