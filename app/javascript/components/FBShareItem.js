import React from 'react';

import { image } from './lib/helpers';

export const FBShareItem = React.createClass({
    propTypes: {
        count: React.PropTypes.number,
        done: React.PropTypes.func,
        fa: React.PropTypes.string,
        iri: React.PropTypes.string,
        title: React.PropTypes.string,
        type: React.PropTypes.string,
        updateCount: React.PropTypes.func,
        url: React.PropTypes.string
    },

    componentDidMount () {
        this.fetchCount();
    },

    handleClick (e) {
        if (typeof FB !== 'undefined') {
            e.preventDefault();
            FB.ui({
                method: 'share',
                href: this.props.url,
                caption: this.props.title
            }, () => {
                this.props.done();
            });
        }
    },

    countInParentheses () {
        return this.props.count > 0 ? `(${this.props.count})` : '';
    },

    fetchCount () {
        $.getJSON(`https://graph.facebook.com/?id=${this.props.iri}`, data => {
            this.props.updateCount('facebook', data.share.share_count);
        });
    },

    render () {
        return (<div className={`link ${this.props.type}`}>
            <a data-turbolinks="false" href={this.props.url} onClick={this.handleClick} target="_blank">
                {image({ fa: this.props.fa })}
                <span className="icon-left">{this.props.title} {this.countInParentheses()}</span>
            </a>
        </div>);
    }
});

export default FBShareItem;
