import { combineReducers } from 'redux';
import profiles from './profiles';
import votes from './votes';

const rootReducer = combineReducers({
    profiles,
    votes
});

export default rootReducer;
