import React from 'react';

export const VoteStats = React.createClass({

    render: function () {
        let { pro, neutral, con } = this.props;

        return (
            <div>
                <div className='details-part details-part--pro' data-title="Aantal stemmen voor">
                    <span className="fa fa-thumbs-up" />
                    <span className="icon-left">{pro}</span>
                </div>
                <div className='details-part details-part--neutral' data-title="Aantal 'geen van beiden'">
                    <span className="fa fa-pause" />
                    <span className="icon-left">{neutral}</span>
                </div>
                <div className='details-part details-part--con' data-title="Aantal stemmen tegen">
                    <span className="fa fa-thumbs-down" />
                    <span className="icon-left">{con}</span>
                </div>
            </div>
        );
    }

});

window.VoteStats = VoteStats;