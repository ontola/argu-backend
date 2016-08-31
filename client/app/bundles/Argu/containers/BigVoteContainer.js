import { connect } from 'react-redux';
import BigVote from '../components/BigVote';

function mapStateToProps(state) {
  if (state.motions.currentId) {
    const motion = state
      .motions
      .records
      .find(m => m.id === state.motions.currentId);
    return state
      .votes
      .records
      .find(v => v.voteableType === 'motions' && v.voteableId === motion.id);
  }
  return {};
}

export default connect(mapStateToProps)(BigVote);
