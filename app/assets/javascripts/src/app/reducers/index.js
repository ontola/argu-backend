import { combineReducers } from 'redux';
import timelines from './timelines';
import points from './points';
import updates from './updates';
import phases from './phases';

const rootReducer = combineReducers({
    timelines,
    points,
    phases,
    updates
});

export default rootReducer;
