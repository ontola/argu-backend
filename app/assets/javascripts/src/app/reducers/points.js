import { Map, List } from 'immutable';
import RPoint from '../records/RPoint';
import { SET_ACTIVE_POINT, POPSTATE } from '../constants/ActionTypes';
/**
 * Points reducer
 * @author Fletcher91 <thom@argu.co>
 */

const initialState = new Map({
    activePointId: -1,
    activePoint: new RPoint(),
    collection: new List()
});

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
