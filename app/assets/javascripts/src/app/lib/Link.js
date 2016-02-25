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
        activeStyle: React.PropTypes.object,
        activeClassName: React.PropTypes.string,
        hash: React.PropTypes.string,
        isButton: React.PropTypes.bool,
        onlyActiveOnIndex: React.PropTypes.bool, //.isRequired,
        onClick: React.PropTypes.func,
        query: React.PropTypes.object,
        state: React.PropTypes.object,
        style: React.PropTypes.object,
        to: React.PropTypes.string //.isRequired,
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

    className: function () {
        const { className, isButton } = this.props;
        return [
            className,
            isButton && isButton === true && 'btn'
        ].join(' ');
    },

    render: function render () {
        const { children, style } = this.props;


        return (<a href={this.href()}
                   style={style}
                   onClick={this.onClick}
                   className={this.className()}
                   data-turbolinks="false">
            {children}
        </a>)
    }
});
export default Link;
window.Link = Link;
