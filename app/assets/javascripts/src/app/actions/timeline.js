/**
 * All the actions in regards to the timeline
 * @author Fletcher91 <thom@argu.co>
 */

import * as Types from '../constants/ActionTypes';

/**
 * Sets the active {@link Timeline}
 * @action TimeLine/SET_ACTIVE_POINT
 */
export function setActiveTimeline(timelineId) {
    return {
        type: Types.SET_ACTIVE_TIMELINE,
        timelineId: timelineId
    }
}

/**
 * Sets the active {@link Point} for the TimeLine
 * @action TimeLine/SET_ACTIVE_POINT
 */
export function setCurrentPhase(phaseId) {
    return {
        type: Types.SET_CURRENT_PHASE,
        payload: {
            phaseId: phaseId
        }
    }
}
