import { connect } from 'react-redux';
import { voteCreate } from '../actions';
import VoteButton from '../components/VoteButton';

const initialState = {
  votes: {
    records: [],
  },
};

function mapDispatchToProps(dispatch, { voteableId, voteableType, side }) {
  return {
    clickHandler: (e) => {
      e.preventDefault();
      dispatch(voteCreate(voteableType, voteableId, side));
    },
  };
}

function mapStateToProps(state = initialState, { side, voteableId, voteableType }) {
  const vote = state.votes.records &&
    state
      .votes
      .records
      .find(v =>
        v.voteableType === voteableType &&
        v.voteableId === voteableId
      );
  return Object.assign({}, vote, { side, turbolinks: state.session.userState === 'guest' });
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(VoteButton);
