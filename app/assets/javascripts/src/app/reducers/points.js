import { Map, List } from 'immutable';
import RPoint from '../records/RPoint';
import { SET_ACTIVE_POINT, POPSTATE } from '../constants/ActionTypes';

/**
 * Points state tree structure definition
 * @param {number} activePointId The id of the currently active point.
 * @param {RPoint} activePoint A reference to the object instance in the collection with activePointId
 * @param {!List} collection All the points currently in the system.
 */
const initialState = new Map({
    activePointId: null,
    activePoint: null,
    collection: new List()
});

/**
 * Points reducer
 * @author Fletcher91 <thom@argu.co>
 */
export default function points(state = initialState, action) {
    switch (action.type) {
        case SET_ACTIVE_POINT:
            return state.withMutations((mutState) => {
                mutState.set('activePointId', action.pointId);
                mutState.set('activePoint',
                    state
                        .get('collection')
                        .find(p => {
                            return p.id === action.pointId;
                        }))
            });
        case POPSTATE:
            debugger;
            return action.stateTree.points;
        default:
            return state;
    }
};
