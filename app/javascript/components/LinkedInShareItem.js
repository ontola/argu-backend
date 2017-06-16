import React from 'react';

import { image } from './lib/helpers';

export const LinkedInShareItem = React.createClass({
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

    countInParentheses () {
        return this.props.count > 0 ? `(${this.props.count})` : '';
    },

    fetchCount () {
        $.getJSON(`https://www.linkedin.com/countserv/count/share?url=${this.props.iri}&callback=?`, data => {
            this.updateCount('linkedIn', data.count);
        });
    },

    handleMouseDown () {
        // Fixes an issue where firefox bubbles events instead of capturing them
        // See: https://github.com/facebook/react/issues/2011
        const dataMethod = ReactDOM.findDOMNode(this).getAttribute('data-method');
        if (dataMethod !== 'post' && dataMethod !== 'put' && dataMethod !== 'patch' && dataMethod !== 'delete') {
            ReactDOM.findDOMNode(this).getElementsByTagName('a')[0].click();
            this.props.done();
        }
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
export default LinkedInShareItem;
