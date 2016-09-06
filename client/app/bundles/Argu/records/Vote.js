import { Map } from 'immutable';
import * as actions from '../actions';
import { APIDesc, apiModelGenerator } from './utils/apiModelGenerator';

const apiDesc = new APIDesc({
  actions: new Map({
    create: actions.CREATE_VOTE,
  }),
  endpoint: 'v.json_api',
  type: 'votes',
});

const attributes = {
  id: null,
  individual: false,
  side: '',
  voteableId: '',
  voteableType: '',
  voterId: '',
  voterType: '',
};

export default apiModelGenerator(attributes, apiDesc);
