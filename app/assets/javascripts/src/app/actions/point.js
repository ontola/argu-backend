/**
 * All the actions in regards to the timeline
 * @author Fletcher91 <thom@argu.co>
 */

import * as Types from '../constants/ActionTypes';


/**
 * Sets the active {@link Point}
 * @action TimeLine/SET_ACTIVE_POINT
 */
export function setActivePoint(pointId) {
    return {
        type: Types.SET_ACTIVE_POINT,
        pointId: pointId
    };
}

/**
 * Switches the current active point to the next.
 * @note These do not work in modulus.
 * @action TimeLine/NEXT_POINT
 */
export function nextPoint(timelineId) {
    return {
        type: Types.NEXT_POINT,
        timelineId: timelineId
    };
}

/**
 * Switches the current active point to the previous.
 * @note These do not work in modulus.
 * @action TimeLine/PREVIOUS_POINT
 */
export function previousPoint(timelineId) {
    return {
        type: Types.PREVIOUS_POINT,
        timelineId: timelineId
    };
}
