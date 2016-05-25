import { combineReducers } from 'redux';
import profiles from './profiles';
import votes from './votes';

const rootReducer = combineReducers({
    arguments,
    profiles,
    votes
});

export default rootReducer;
