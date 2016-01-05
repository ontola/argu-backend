import { combineReducers } from 'redux';
import timelines from './timelines';
import points from './points';
import updates from './updates';
import phases from './phases';
import profiles from './profiles';
import plannings from './plannings';

const rootReducer = combineReducers({
    timelines,
    points,
    phases,
    updates,
    profiles,
    plannings
});

export default rootReducer;
