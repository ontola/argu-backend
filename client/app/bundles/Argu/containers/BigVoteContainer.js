import { connect } from 'react-redux';

import BigVote from 'components/BigVote';
import { getVote } from 'state/votes/selectors';

function mapStateToProps(state, { motionId, voteId }) {
  if (voteId) {
    const { 
      side,
      voteableId,
      voteableType,
    } = getVote(state, voteId);
    return { voteId, side, voteableId, voteableType };
  }
  return { voteableId: motionId.toString(), voteableType: 'motions' };
}

export default connect(mapStateToProps)(BigVote);
