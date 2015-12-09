import RPhase from '../records/RPhase';

const initialState = [
    new RPhase()
];

export default function phases(state = initialState, action) {
    switch (action.type) {
        default:
            return state;
    }
};
