import { handleActions } from 'redux-actions';
import { Map } from 'immutable';

import Vote from 'models/Vote';

import {
  CREATE_VOTE,
} from 'actions';

const initialState = new Map({
  items: new Map(),
});

const votes = handleActions({
  [CREATE_VOTE]: (state, { payload }) => {
    debugger;
    return state;
  },
}, initialState);

export default votes;
