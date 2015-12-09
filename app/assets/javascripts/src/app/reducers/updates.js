import RUpdate from '../records/RUpdate';

const initialState = [
    new RUpdate()
];

export default function updates(state = initialState, action) {
    switch (action.type) {
        default:
            return state;
    }
};
