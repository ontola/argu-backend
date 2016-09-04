import { Map, Set } from 'immutable';
import * as actions from '../actions';
import { APIDesc, apiModelGenerator } from './utils/apiModelGenerator';

const apiDesc = new APIDesc({
  actions: new Map(),
  endpoint: 'currentActor',
  type: 'current-actors',
});

const attributes = {
  id: '',
  userState: 'guest',
  memberships: new Set(),
  discover: new Set(),
};

export default apiModelGenerator(attributes, apiDesc);
