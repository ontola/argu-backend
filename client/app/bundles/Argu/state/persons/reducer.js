import { handleActions } from 'redux-actions';
import { Map } from 'immutable';
import Person from '../../models/Person';
import {
  GET_PERSON,
} from '../action-types';

const initialState = new Map({
  items: new Map(),
});

const newPersonUnlessExists = (state, id) => {
  const record = state.getIn(['items', id]);
  return record !== undefined ? record : new Person({ id });
};

let record;

const persons = handleActions({
  [GET_PERSON]: (state, { payload }) => {
    record = payload.record || newPersonUnlessExists(state, payload.id);
    return state.setIn(['items', record.id], record);
  },
}, initialState);

export default persons;
