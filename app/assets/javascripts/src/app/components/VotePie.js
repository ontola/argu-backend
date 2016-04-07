import React from 'react';
import PieChart from 'react-simple-pie-chart';
import StylingVars from '../mixins/StylingVars';

export const VotePie = React.createClass({
    propTypes: {
        pro: React.PropTypes.number.isRequired,
        neutral: React.PropTypes.number.isRequired,
        con: React.PropTypes.number.isRequired
    },

    notVotedStyle: function () {
        return [
            {
                color: '#e8e8e8',
                value: 1
            }
        ];
    },

    style: function () {
        let { pro, neutral, con } = this.props;

        let totalVotesCount = pro + neutral + con;
        let scaleRatio = 1;
        if (totalVotesCount < 5) {
            scaleRatio = .25 + .75 * (totalVotesCount / 5);
        }
        let transform = `scale(${scaleRatio})`;
        return {
            WebkitTransform: transform,
            MozTransform: transform,
            msTransform: transform,
            OTransform: transform,
            transform: transform
        };
    },

    votedStyle: function () {
        let { pro, neutral, con } = this.props;

        return [
            {
                color: StylingVars.pro,
                value: pro
            },
            {
                color: StylingVars.neutral,
                value: neutral
            },
            {
                color: StylingVars.con,
                value: con
            }
        ];
    },


    render: function () {
        let { pro, neutral, con } = this.props;

        if (pro + con + neutral > 0) {
            return (
                <div className='vote-pie' style={this.style()} data-title="">
                    <PieChart slices={this.votedStyle()} />
                </div>
            );
        } else {
            return (
                <div className='vote-pie vote-pie--empty'>
                    <PieChart slices={this.notVotedStyle()} />
                </div>
            );
        }
    }
});

window.VotePie = VotePie;
