import { Map, List } from 'immutable';
import {
    SET_ACTIVE_POINT,
    NEXT_POINT,
    POPSTATE
} from '../constants/ActionTypes';

/**
 * Points state tree structure definition
 * @param {number} activePointId The id of the currently active point.
 * @param {RPoint} activePoint A reference to the object instance in the collection with activePointId
 * @param {!List} collection All the points currently in the system.
 */
const initialState = new Map({
    activePointId: null,
    activePoint: null,
    collection: new Map()
});

function nextPointByDate(state) {
    const sortedCol = state
        .get('collection')
        .sort(p => {
            return p.sortDate;
        });
    const currentIndex = sortedCol
        .findIndex(p => {
            return p.get('id') === state.get('activePointId')
        });

    if (currentIndex === sortedCol.count() - 1) {
        return null;
    } else {
        return sortedCol.get(currentIndex + 1);
    }
}

/**
 * Points reducer
 * @author Fletcher91 <thom@argu.co>
 */
export default function points(state = initialState, action) {
    switch (action.type) {
        case SET_ACTIVE_POINT:
            return state.withMutations((mutState) => {
                mutState.set('activePointId', action.payload.pointId);
                mutState.set('activePoint',
                    state.getIn(['collection', action.payload.pointId]))
            });
        case NEXT_POINT:
            const next = nextPointByDate(state);
            return state.withMutations((mutState) => {
                mutState.set('activePointId', next && next.get('id'));
                mutState.set('activePoint', next);
            });
        case POPSTATE:
            return action.payload.stateTree.points;
        default:
            return state;
    }
};
