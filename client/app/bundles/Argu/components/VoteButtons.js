import React, { Component, PropTypes } from 'react';
import VoteButtonContainer from '../containers/VoteButtonContainer';

const propTypes = {
  actor: PropTypes.object,
  buttonsType: PropTypes.string,
  currentVote: PropTypes.string,
  distribution: PropTypes.object,
  voteableId: PropTypes.string,
  voteableType: PropTypes.string,
  percent: PropTypes.object,
  vote_url: PropTypes.string,
};

class VoteButtons extends Component {
  buttonsClassName() {
    switch (this.props.buttonsType) {
      case 'subtle':
        return 'btns-opinion--subtle';
      case 'big':
      default:
        return 'btns-opinion';
    }
  }

  render() {
    const { actor, distribution, voteableType, voteableId, currentVote } = this.props;
    const voteButtons = ['pro', 'neutral', 'con']
      .map((buttonSide, i) => (
        <VoteButtonContainer
          actor={actor}
          clickHandler={this.props[`${buttonSide}Handler`]}
          count={distribution[buttonSide]}
          current={currentVote === buttonSide}
          key={i}
          voteableType={voteableType}
          voteableId={voteableId}
          side={buttonSide}
        />
      ));

    return (
      <ul
        className={this.buttonsClassName()}
        data-voted={(currentVote &&
                     currentVote.length > 0 &&
                     currentVote !== 'abstain') || null}
      >
        {voteButtons}
      </ul>
    );
  }
}

VoteButtons.propTypes = propTypes;

export default VoteButtons;
