import { Map, List } from 'immutable';

/**
 * Plannings state tree structure definition
 * @param {List.RPlanning} collection All the Plannings currently in the system.
 */
const initialState = new Map({
    collection: new List()
});


/**
 * Plannings reducer
 * @author Fletcher91 <thom@argu.co>
 */
export default function timelines(state = initialState, action) {
    switch (action.type) {
        default:
            return state;
    }
}
