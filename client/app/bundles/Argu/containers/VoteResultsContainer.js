import { connect } from 'react-redux';

import { getMotion } from 'state/motions/selectors';
import VoteResults from '../components/VoteResults';

function mapStateToProps(state, { voteableId, voteableType }) {
  return getMotion(state, { motionId: voteableId }).distribution;
}

export default connect(
  mapStateToProps
)(VoteResults);
