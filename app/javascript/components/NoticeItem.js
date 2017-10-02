import React from 'react';

export const NoticeItem = React.createClass({
    propTypes: {
        data: React.PropTypes.shape({
            'turbolinks': React.PropTypes.string
        }),
        divider: React.PropTypes.string,
        done: React.PropTypes.func,
        fa: React.PropTypes.string,
        image: React.PropTypes.object,
        title: React.PropTypes.string,
        type: React.PropTypes.string,
        url: React.PropTypes.string
    },

    render () {
        let divider, turbolinks;
        if (this.props.divider && this.props.divider === 'top') {
            divider = <div className="dropdown-divider"></div>;
        }
        if (this.props.data) {
            turbolinks = this.props.data['turbolinks'];
        }

        return (<div className="dropdown-notice">
            {divider}
            <span className={(this.props.image || this.props.fa) ? 'icon-left' : ''}>{this.props.title}</span>
        </div>);
    }
});

export default NoticeItem;
