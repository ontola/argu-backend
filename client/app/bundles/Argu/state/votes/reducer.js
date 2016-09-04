import { handleActions } from 'redux-actions';
import { Map } from 'immutable';

import Vote from 'models/Vote';

import {
  SET_VOTE,
} from 'actions';

const initialState = new Map({
  items: new Map(),
});

const votes = handleActions({
  [SET_VOTE]: (state, { payload }) => {
    const record = new Vote({
      id: payload.motionId,
      individual: true,
      value: payload.side,
    });
    return state.setIn(['items', payload.motionId], record);
  },
}, initialState);

export default votes;
