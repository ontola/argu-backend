import React from 'react';

import { image } from './lib/helpers';

export const FBShareItem = React.createClass({
    propTypes: {
        count: React.PropTypes.number,
        done: React.PropTypes.func,
        shareUrl: React.PropTypes.string,
        title: React.PropTypes.string,
        type: React.PropTypes.string,
        url: React.PropTypes.string
    },

    handleClick (e) {
        if (typeof FB !== 'undefined') {
            e.preventDefault();
            FB.ui({
                method: 'share',
                href: this.props.shareUrl,
                caption: this.props.title
            }, () => {
                this.props.done();
            });
        }
    },

    countInParentheses () {
        return this.props.count > 0 ? `(${this.props.count})` : '';
    },

    render () {
        return (<div className={`link ${this.props.type}`}>
            <a data-turbolinks="false" href={this.props.url} onClick={this.handleClick} target="_blank">
                {image({ fa: 'fa-facebook' })}
                <span className="icon-left">Facebook {this.countInParentheses()}</span>
            </a>
        </div>);
    }
});

export default FBShareItem;
