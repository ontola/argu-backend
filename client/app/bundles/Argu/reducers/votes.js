import { VOTE_CREATE_SUCCESS } from '../actions';
import { replaceIndexedItem } from '../lib/Array';

const initialState = [];

export default function votes(state = initialState, action) {
  switch (action.type) {
    case VOTE_CREATE_SUCCESS: {
      const { voteableId, voteableType } = action.payload.vote;

      const voteIndex = state
        .records
        .findIndex(vote =>
          vote.voteableId === voteableId &&
          vote.voteableType === voteableType
        );

      let newRecords;
      if (voteIndex >= 0) {
        const vote = Object.assign({}, state.records[voteIndex], action.payload.vote);
        newRecords = replaceIndexedItem(state.records, voteIndex, vote);
      } else {
        newRecords = [action.payload.vote, ...state.records];
      }

      return Object.assign(
        {},
        state,
        {
          records: newRecords,
        }
      );
    }
    default:
      return state;
  }
}
