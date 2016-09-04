import { Map } from 'immutable';
import * as actions from 'actions';
import { APIDesc, apiModelGenerator } from './utils/apiModelGenerator';

const apiDesc = new APIDesc({
  actions: new Map({
    collection: actions.GET_PERSONS,
    resource: actions.GET_PERSON,
  }),
  endpoint: 'persons',
  type: 'persons',
});

const attributes = {
  id: null,
  name: '',
  image: '',
  biography: '',
  party: '',
};

export default apiModelGenerator(attributes, apiDesc);
