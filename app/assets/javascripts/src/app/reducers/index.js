import { combineReducers } from 'redux';
import timelines from './timelines';
import updates from './updates';
import phases from './phases';

const rootReducer = combineReducers({
    timelines,
    phases,
    updates
});

export default rootReducer;
