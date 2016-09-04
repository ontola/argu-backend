import { createSelector } from 'reselect';

import { getMotionId } from 'state/motions/selectors';

export const getVotes = (state) => state.getIn(['votes', 'items']);

export const getVoteByMotionId = createSelector(
  [getVotes, getMotionId],
  (votes, motionId) => {
    if (votes.get(motionId) === undefined) {
      return '';
    }
    return votes.getIn([motionId, 'value']);
  }
);
