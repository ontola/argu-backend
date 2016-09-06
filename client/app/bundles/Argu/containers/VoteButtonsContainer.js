import { connect } from 'react-redux';

import { getMyVoteByVoteable } from 'state/votes/selectors';
import { getMotion } from 'state/motions/selectors';
import VoteButtons from '../components/VoteButtons';

function mapStateToProps(state, { voteId, voteableId, voteableType }) {
  const vote = getMyVoteByVoteable(state, voteableId, voteableType);
  const motion = getMotion(state, { motionId: voteableId });
  return Object.assign(
    {},
    {
      actor: vote.voter,
      currentVote: vote.side,
      voteableId: vote.voteableId,
      voteableType: vote.voteableType,
    },
    { distribution: motion.distribution },
  );
}

export default connect(
  mapStateToProps
)(VoteButtons);
