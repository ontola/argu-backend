import React, { Component, PropTypes } from 'react';
import VoteButtonsContainer from '../containers/VoteButtonsContainer';
import VoteResultsContainer from '../containers/VoteResultsContainer';

const propTypes = {
  actor: PropTypes.object,
  side: PropTypes.string,
  distribution: PropTypes.object,
  voteableId: PropTypes.string,
  voteableType: PropTypes.string,
  percent: PropTypes.object,
  vote_url: PropTypes.string,
};

/**
 * Component that displays current vote options based on whether the user is member of a group.
 * Also reveals the results if the user has already voted.
 * This component is not pure.
 * @class
 * @exports BigVote
 * @see {@linkcode Vote.VoteButtons}
 * @see {@linkcode Vote.VoteResults}
 */
class BigVote extends Component {
  constructor(props) {
    super(props);
    this.state = {
      actor: this.props.actor || null,
    };
  }

  render() {
    const { voteableType, voteableId, side } = this.props;
    let voteButtonsComponent;
    let voteResultsComponent;
    if (!this.state.actor || this.state.actor.actor_type === 'User') {
      voteButtonsComponent = (
        <VoteButtonsContainer
          voteableType={voteableType}
          voteableId={voteableId}
        />
      );
      if (side !== 'abstain') {
        voteResultsComponent = (
          <VoteResultsContainer
            voteableType={voteableType}
            voteableId={voteableId}
          />
        );
      }
    } else if (this.state.actor.actor_type === 'Page') {
      voteResultsComponent = (
        <VoteResultsContainer
          voteableType={voteableType}
          voteableId={voteableId}
        />
      );
    }

    return (
      <div className="center motion-shr">
        {voteButtonsComponent}
        {voteResultsComponent}
      </div>
    );
  }
}

BigVote.propTypes = propTypes;

export default BigVote;
