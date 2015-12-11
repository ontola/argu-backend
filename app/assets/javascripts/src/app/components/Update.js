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
        const { title, content } = this.props;
        return (
            <div className="update">
                <h2 className="update">{title}</h2>
                <p>{content}</p>
            </div>
        );
    }
});

export default Update;
