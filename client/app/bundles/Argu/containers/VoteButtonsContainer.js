import { connect } from 'react-redux';
import VoteButtons from '../components/VoteButtons';

function mapStateToProps(state, { voteableId, voteableType }) {
  const motion = state
    .motions
    .records
    .find(m => m.id === state.motions.currentId);
  const vote = state
    .votes
    .records
    .find(v =>
      v.voteableType === voteableType &&
      v.voteableId === voteableId
    );
  return Object.assign(
    {},
    vote,
    { distribution: motion.distribution || {} }
  );
}

export default connect(
  mapStateToProps
)(VoteButtons);
