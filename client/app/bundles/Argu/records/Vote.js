import { Map } from 'immutable';
import * as actions from '../actions';
import { APIDesc, apiModelGenerator } from './utils/apiModelGenerator';

const apiDesc = new APIDesc({
  actions: new Map({
    collection: actions.GET_VOTES,
    resource: actions.GET_VOTE,
  }),
  endpoint: 'votes',
  type: 'votes',
});

const attributes = {
  id: null,
  individual: false,
  value: '',
};

export default apiModelGenerator(attributes, apiDesc);
