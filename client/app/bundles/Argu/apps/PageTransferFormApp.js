import React from 'react';
import { Provider } from 'react-redux';
import ReactOnRails from 'react-on-rails';
import PageTransferFrom from '../components/forms/PageTransferForm';

const PageTransferFormApp = props => (
  <Provider store={ReactOnRails.getStore('arguStore')}>
    <PageTransferFrom {...props} />
  </Provider>
);

export default PageTransferFormApp;
