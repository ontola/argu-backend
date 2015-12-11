import { Map } from 'immutable';
import RTimeLine from '../records/RTimeLine';
import { SET_ACTIVE_POINT } from '../constants/ActionTypes';

const initialState = new Map({});

export default function timelines(state = initialState, action) {
    switch (action.type) {
        case SET_ACTIVE_POINT:
            const newTimeline = Object.assign({},
                                              state[action.timelineId],
                                              {activePointId: action.activePointId});

            return Object.assign({}, state, {
                [action.timelineId]: newTimeline
            });
        default:
            return state;
    }
};
