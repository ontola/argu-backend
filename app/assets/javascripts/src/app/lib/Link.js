import React from 'react';
import url from 'url';
window.url = url;

import store from '../stores/store';

/**
 * Custom wrapper until we can use react-router's Link that creates generic `a` tags.
 * If the `onClick` prop is passed, it blocks the default action and pushes the url to history.
 * @class Link
 * @author Fletcher91 <thom@argu.co>
 */
export const Link = React.createClass({
    propTypes: {
        to: React.PropTypes.string, //.isRequired,
        query: React.PropTypes.object,
        hash: React.PropTypes.string,
        state: React.PropTypes.object,
        activeStyle: React.PropTypes.object,
        activeClassName: React.PropTypes.string,
        onlyActiveOnIndex: React.PropTypes.bool, //.isRequired,
        onClick: React.PropTypes.func
    },

    href: function href () {
        const { to, query, hash } = this.props;

        return url.format({
            pathname: to,
            query,
            hash
        });
    },

    onClick: function (e) {
        const { onClick } = this.props;

        if (typeof onClick !== 'undefined') {
            e.preventDefault();
            onClick(e);
            if (typeof history.pushState === 'function') {
                history.pushState(store.getState(), document.title, this.href());
            }
        }
    },

    render: function render () {
        const { children } = this.props;

        return (<a href={this.href()}
                   onClick={this.onClick}
                   data-skip-pjax="true">
            {children}
        </a>)
    }
});
export default Link;
window.Link = Link;
