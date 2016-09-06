import { connect } from 'react-redux';

import { getActor } from 'state/currentActors/selectors';
import { getMyVoteByVoteable } from 'state/votes/selectors';
import Vote from '../records/Vote';
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
      dispatch(Vote.create({
        type: 'votes',
        attributes: { side: side },
        relationships: {
          parent: {
            data: {type: voteableType, id: voteableId}
          }
        }
      }));
    },
  };
}

function mapStateToProps(state = initialState, { side, voteableId, voteableType }) {
  const vote = getMyVoteByVoteable(state, voteableId, voteableType);
  return Object.assign({}, vote, { side, turbolinks: getActor(state).userState === 'guest' });
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(VoteButton);
