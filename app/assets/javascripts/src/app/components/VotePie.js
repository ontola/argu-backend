import React from 'react';
import PieChart from 'react-simple-pie-chart';
import StylingVars from '../mixins/StylingVars';

export const VotePie = React.createClass({

    render: function () {
        let { pro, neutral, con } = this.props.voteCounts;

        if (pro !== 0 || con !== 0 || neutral !== 0) {
            return (
                <div className='vote-pie'>
                    <PieChart
                        slices={[
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
                    ]}
                    />
                </div>
            );
        } else {
            return (
                <div className='vote-pie vote-pie--empty'>
                    <PieChart
                        slices={[
                        {
                          color: '#e8e8e8',
                          value: 1
                        }
                    ]}
                    />
                </div>
            )
        }
    }
});

window.VotePie = VotePie;
