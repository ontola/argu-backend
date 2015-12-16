/**
 * Timelines reducer
 * @author Fletcher91 <thom@argu.co>
 */

import { Map, OrderedSet } from 'immutable';
import {
    SET_ACTIVE_POINT,
    NEXT_POINT,
    PREVIOUS_POINT
} from '../constants/ActionTypes';

const initialState = new Map({
    collection: new Map({}),
    order: new OrderedSet([])
});

function replaceTimeline(state, timeline) {
    return state.setIn(
        ['collection', timeline.id.toString()],
        timeline
    );
}

/**
 * @private
 * Creates a new timeline with {@param newMembers} values replaced.
 * @param timeline
 * @param newMembers
 */
function updateTimeline(timeline, newMembers) {
    return timeline.merge(
        timeline,
        newMembers
    );
}

/**
 * @private
 * Returns a timeline from the state for an action or an id.
 * @param idOrAction The action object or the timeline id.
 * @returns {RTimeline}
 */
function getTimeline(state, idOrAction) {
    return state.getIn([
        'collection',
        tId(idOrAction).toString()
    ]);
}

/**
 * @private
 * Returns the id of the timeline an action is meant for.
 * Also returns the instance if it's not an object for shorthand usage.
 * @param action The action object or the id
 * @returns {number} The id of the timeline.
 */
function tId(idOrAction) {
    return parseInt(
        typeof idOrAction === 'object'
            ? (idOrAction.timelineId || 0)
            : idOrAction);
}

/**
 * Composite function to update attributes on an action defined timeline.
 * @param newMembers {object} A key value object for the new member values.
 */
function updateTimelineInState(state, action, newMembers) {
    const currentTimeline = getTimeline(state, action);
    return replaceTimeline(
        state,
        updateTimeline(
            currentTimeline,
            newMembers
        ));
}

export default function timelines(state = initialState, action) {
    const currentTimeline = getTimeline(state, action);
    console.log('timeline action fired', action);
    switch (action.type) {
        case SET_ACTIVE_POINT:
            return updateTimelineInState(
                state,
                action,
                {activePointId: action.activePointId}
            );
        case NEXT_POINT:
            return updateTimelineInState(
                state,
                action,
                {activePointId: currentTimeline.activePointId + 1}
            );
        case PREVIOUS_POINT:
            return updateTimelineInState(
                state,
                action,
                {activePointId: currentTimeline.activePointId - 1}
            );
        default:
            return state;
    }
};
