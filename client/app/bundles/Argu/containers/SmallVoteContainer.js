import { connect } from 'react-redux';
import VoteButtons from '../components/VoteButtons';

const initialState = {
  arguments: {
    records: [],
  },
  motions: {
    records: [],
  },
  votes: {
    records: [],
  },
};

function mapStateToProps(state = initialState, ownProps) {
  const voteable = state[ownProps.voteableType] &&
    state[ownProps.voteableType].records &&
    state[ownProps.voteableType]
      .records
      .find(v => v.id === ownProps.voteableId);

  const vote = state.votes &&
    state.votes.records &&
    state
      .votes
      .records
      .find(v =>
        v.voteableType === ownProps.voteableType &&
        v.voteableId === ownProps.voteableId);

  return Object.assign(
    {},
    {
      buttonsType: 'subtle',
      distribution: voteable && voteable.distribution,
    },
    ownProps,
    vote
  );
}

export default connect(
  mapStateToProps
)(VoteButtons);
