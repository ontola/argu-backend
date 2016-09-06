import { createSelector } from 'reselect';

import { getActor } from 'state/currentActors/selectors';

export const getVotes = state => state.getIn(['votes', 'items']);

export const getVote = (state, voteId) => state.getIn(['votes', 'items', voteId.toString()]);

export const getVotesByVoteable = createSelector(
  getVotes,
  (_, voteableId) => voteableId,
  (_, __, voteableType) => voteableType,
  (votes, voteableId, voteableType) => {
    return votes.filter(v => v.voteableId === voteableId && v.voteableType === voteableType);
  }
);

export const getMyVoteByVoteable = createSelector(
  getVotesByVoteable,
  getActor,
  (votes, { actorType, actorId }) => votes.find(
    v => v.voterType === actorType && v.voterId === actorId
  )
);
