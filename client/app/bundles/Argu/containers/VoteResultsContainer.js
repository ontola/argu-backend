import { connect } from 'react-redux';
import VoteResults from '../components/VoteResults';

function mapStateToProps(state, { voteableId, voteableType }) {
  const motion = state
    [voteableType]
    .records
    .find(m => m.id === voteableId);
  return motion.distribution;
}

export default connect(
  mapStateToProps
)(VoteResults);
