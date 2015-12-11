import * as Types from '../constants/ActionTypes';

/**
 * Sets the active {@link Point} for the TimeLine
 * @action TimeLine/SET_ACTIVE_POINT
 * @author Fletcher91 <thom@argu.co>
 */
export function setActivePoint(timelineId, pointId) {
    return {
        type: Types.SET_ACTIVE_POINT,
        timelineId: timelineId,
        activePointId: pointId
    };
}

export function setCurrentPhase(phaseId) {
    return {
        type: Types.SET_CURRENT_PHASE,
        phaseId: phaseId
    }
}
