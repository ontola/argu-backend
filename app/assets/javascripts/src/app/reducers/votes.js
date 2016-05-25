import { CLOSE_OPINION_FORM, VOTE_SUCCESS } from '../actions';

const initialState = {};

/**
 * Votes reducer
 * @author Fletcher91 <thom@argu.co>
 * @param {object} state - The current stored state.
 * @param {object} action - The action.
 * @return {object} state - The new state
 */
export default function votes(state = initialState, action) {
    switch (action.type) {
    case VOTE_SUCCESS: {
        let updatedState = {};
        if (action.payload.vote) {
            const { distribution, percent, side, voteId } = action.payload.vote;
            const updatedVotes = state.votes;
            updatedVotes[voteId] = Object.assign({}, updatedVotes[voteId], { side })
            updatedState = Object.assign(updatedState, {
                currentVoteId: voteId,
                distribution,
                percent,
                votes: updatedVotes
            });
        }
        return Object.assign({}, state, updatedState);
            { opinionFormOpened: true },
    }
    case CLOSE_OPINION_FORM:
        return Object.assign({}, state, {
            opinionFormOpened: false
        });
    default:
        return state;
    }
}
