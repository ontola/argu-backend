import { Map } from 'immutable';
import * as actions from '../actions';
import { APIDesc, apiModelGenerator } from './utils/apiModelGenerator';

const apiDesc = new APIDesc({
  actions: new Map({
    collection: actions.GET_MOTIONS,
    resource: actions.GET_MOTION,
  }),
  endpoint: 'motions',
  type: 'motions',
});

const attributes = {
  id: null,
  loading: false,
  title: '',
  text: '',
  createdAt: null,
  creator: null,
  classification: 'Motie',
  arguments: [],
  voteEvent: [],
};

export default apiModelGenerator(attributes, apiDesc);
