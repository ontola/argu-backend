import { Map } from 'immutable';
import * as actions from '../actions';
import { APIDesc, apiModelGenerator } from './utils/apiModelGenerator';

const apiDesc = new APIDesc({
  actions: new Map(),
  endpoint: 'forums',
  type: 'forums',
});

const attributes = {
  id: null,
  loading: false,
  title: '',
  text: '',
  shortname: '',
  'profile-photo': '',
  createdAt: null,
};

export default apiModelGenerator(attributes, apiDesc);
