import React, { Component, PropTypes } from 'react';
import VoteButtonContainer from '../containers/VoteButtonContainer';

const propTypes = {
  actor: PropTypes.object,
  buttonsType: PropTypes.string,
  side: PropTypes.string,
  distribution: PropTypes.object,
  voteableId: PropTypes.number,
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
    const { actor, distribution, voteableType, voteableId, side } = this.props;
    const voteButtons = ['pro', 'neutral', 'con']
      .map((buttonSide, i) => (
        <VoteButtonContainer
          actor={actor}
          clickHandler={this.props[`${buttonSide}Handler`]}
          count={distribution[buttonSide]}
          current={side === buttonSide}
          key={i}
          voteableType={voteableType}
          voteableId={voteableId}
          side={buttonSide}
        />
      ));

    return (
      <ul
        className={this.buttonsClassName()}
        data-voted={(side &&
                     side.length > 0 &&
                     side !== 'abstain') || null}
      >
        {voteButtons}
      </ul>
    );
  }
}

VoteButtons.propTypes = propTypes;

export default VoteButtons;
