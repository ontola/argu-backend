import { Map, OrderedSet } from 'immutable';
import {
    NEXT_POINT,
    PREVIOUS_POINT,
    SET_ACTIVE_TIMELINE
} from '../constants/ActionTypes';

/**
 * Timelines state tree structure definition
 * @param {number} activeTimelineId The id of the currently active {@link RTimeline}.
 * @param {RTimeline} activeTimeline A reference to the object instance in the collection with activeTimelineId
 * @param {Map} collection All the points currently in the system.
 * @param {OrderedSet.<number>} order The point ids in order.
 */
const initialState = new Map({
    activeTimelineId: undefined,
    activeTimeline: undefined,
    activeItemType: '',
    activeItemId: -1,
    collection: new Map({}),
    order: new OrderedSet()
});

/**
 * Timelines reducer
 * @author Fletcher91 <thom@argu.co>
 */
export default function timelines(state = initialState, action) {
    switch (action.type) {
        case SET_ACTIVE_TIMELINE:
            return state.withMutations((mutState) => {
                mutState.set('activeTimelineId', action.payload.timelineId);
                mutState.set('activeTimeline',
                    state
                        .get('collection')
                        .find(t => {
                            return t.id === action.payload.timelineId;
                    }))
            });
        default:
            return state;
    }
};
