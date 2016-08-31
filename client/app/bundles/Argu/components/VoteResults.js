import React, { Component, PropTypes } from 'react';

const HUNDRED_PERCENT = 100;
const SPLIT_IN_THREE = 100;
const LOWER_DISPLAY_LIMIT = 5;
const DEFAULT_TOP_OFFSET = -100;

const propTypes = {
  con: PropTypes.number,
  neutral: PropTypes.number,
  pro: PropTypes.number,
};

/**
 * Component to display voting results
 * @class VoteResults
 * @memberof Vote
 */
class VoteResults extends Component {
  votePercentage(side) {
    const { con, neutral, pro } = this.props;
    const voteCount = this.props[side];
    const totalVoteCount = con + neutral + pro;

    if (totalVoteCount === 0) {
      return SPLIT_IN_THREE;
    } else if (voteCount === 0) {
      return 0;
    }
    return Math.abs(Math.round(voteCount / totalVoteCount * HUNDRED_PERCENT));
  }

  voteWidth(side) {
    const percentages = {
      con: this.votePercentage('con'),
      neutral: this.votePercentage('neutral'),
      pro: this.votePercentage('pro'),
    };
    const supplementedValues = {
      pro: percentages.pro < LOWER_DISPLAY_LIMIT
        ? LOWER_DISPLAY_LIMIT
        : percentages.pro,
      neutral: percentages.neutral < LOWER_DISPLAY_LIMIT
        ? LOWER_DISPLAY_LIMIT
        : percentages.neutral,
      con: percentages.con < LOWER_DISPLAY_LIMIT
        ? LOWER_DISPLAY_LIMIT
        : percentages.con,
    };

    const overflow = Object.keys(supplementedValues)
      .reduce(
        (prev, cur) => prev + supplementedValues[cur],
        DEFAULT_TOP_OFFSET
      );

    const width = supplementedValues[side] - (overflow * (percentages[side] / HUNDRED_PERCENT));

    return {
      width: `${width}%`,
    };
  }

  render() {
    return (
      <ul className="progress-bar progress-bar-stacked">
        <li style={this.voteWidth('pro')}>
          <span className="btn-pro">
            {`${this.votePercentage('pro')}%`}
          </span>
        </li>
        <li style={this.voteWidth('neutral')}>
          <span className="btn-neutral">
            {`${this.votePercentage('neutral')}%`}
          </span>
        </li>
        <li style={this.voteWidth('con')}>
          <span className="btn-con">
            {`${this.votePercentage('con')}%`}
          </span>
        </li>
      </ul>
    );
  }
}

VoteResults.propTypes = propTypes;

export default VoteResults;
