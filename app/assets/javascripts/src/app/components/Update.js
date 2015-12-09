import React from 'react';
import RProfile from '../records/RProfile';

const Update = React.createClass({
    propTypes: {
        id: React.PropTypes.number,
        title: React.PropTypes.string,
        content: React.PropTypes.string,
        creator: React.PropTypes.instanceOf(RProfile)
    },

    render: function render() {
        return (
            <div className="update">

            </div>
        );
    }
});

export default Update;
