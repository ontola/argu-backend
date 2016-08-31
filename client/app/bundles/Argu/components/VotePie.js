import React, { Component, PropTypes } from 'react';
import PieChart from 'react-simple-pie-chart';
import StylingVars from '../mixins/StylingVars';

const VOTE_INTERCEPT = .25;
const VOTE_SLOPE = .75;
const MIN_VOTE_PERC = 5;

const propTypes = {
  con: PropTypes.number.isRequired,
  neutral: PropTypes.number.isRequired,
  pro: PropTypes.number.isRequired,
};

class VotePie extends Component {
  notVotedStyle() {
    return [
      {
        color: '#e8e8e8',
        value: 1,
      },
    ];
  }

  style() {
    const { pro, neutral, con } = this.props;

    const totalVotesCount = pro + neutral + con;
    let scaleRatio = 1;
    if (totalVotesCount < MIN_VOTE_PERC) {
      scaleRatio = VOTE_INTERCEPT + VOTE_SLOPE * (totalVotesCount / MIN_VOTE_PERC);
    }
    const transform = `scale(${scaleRatio})`;
    return {
      WebkitTransform: transform,
      MozTransform: transform,
      msTransform: transform,
      OTransform: transform,
      transform,
    };
  }

  votedStyle() {
    const { pro, neutral, con } = this.props;

    return [
      {
        color: StylingVars.pro,
        value: pro,
      },
      {
        color: StylingVars.neutral,
        value: neutral,
      },
      {
        color: StylingVars.con,
        value: con,
      },
    ];
  }


  render() {
    const { pro, neutral, con } = this.props;
    const voted = pro + con + neutral > 0;
    const style = voted ? this.style() : null;
    const pieChartStyle = voted ? this.votedStyle() : this.notVotedStyle();

    return (
      <div className={`vote-pie ${!voted && 'vote-pie--empty'}`} data-title="" style={style}>
        <PieChart slices={pieChartStyle} />
      </div>
    );
  }
}

VotePie.propTypes = propTypes;

export default VotePie;
