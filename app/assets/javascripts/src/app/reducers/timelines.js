import { Map } from 'immutable';
import RTimeLine from '../records/RTimeLine';

const initialState = new Map({
    1: new RTimeLine({
        id: 1,
        parentUrl: 'https://argu.co/m/543'
    })
});

export default function timelines(state = initialState, action) {
    switch (action.type) {
        default:
            return state;
    }
};
