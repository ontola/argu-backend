import { handleActions } from 'redux-actions';
import { Map } from 'immutable';

import Forum from 'models/Forum';

// import {
//   GET_MOTION,
// } from 'actions';

const initialState = new Map({
  items: new Map(),
});

const forums = handleActions({
}, initialState);

export default forums;
