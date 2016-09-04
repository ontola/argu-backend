import { handleActions } from 'redux-actions';
import { Map } from 'immutable';

import Vote from 'models/CurrentActor';

const initialState = new Map({
  items: new Map(),
});

const currentActors = handleActions({
}, initialState);

export default currentActors;
