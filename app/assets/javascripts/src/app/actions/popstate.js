/**
 * All the actions in regards to the timeline
 * @author Fletcher91 <thom@argu.co>
 */

import * as Types from '../constants/ActionTypes';


/**
 * Sets the active {@link Point}
 * @action TimeLine/SET_ACTIVE_POINT
 */
export default function popstate(stateTree) {
    return {
        type: Types.POPSTATE,
        payload: {
            stateTree: stateTree
        }
    };
}
