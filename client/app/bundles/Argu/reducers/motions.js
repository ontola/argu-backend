import { VOTE_CREATE_SUCCESS } from '../actions';

const initialState = [];

export default function motions(state = initialState, action) {
  switch (action.type) {
    case VOTE_CREATE_SUCCESS: {
      const { voteableId, voteableType } = action.payload.vote;
      if (voteableType !== 'motions') {
        return state;
      }

      const { distribution } = action.payload.vote;

      return Object.assign(
        {},
        state,
        {
          records: state.records.map((motion) => {
            if (motion.id === voteableId) {
              return Object.assign(
                {},
                motion,
                { distribution }
              );
            }
            return motion;
          }),
        }
      );
    }
    default:
      return state;
  }
}
