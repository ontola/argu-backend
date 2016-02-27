// for browserify-rails: module.exports

import React from 'react';
import { safeCredentials } from '../lib/helpers';

export const ActiveToggle = React.createClass({
    getDefaultProps: function() {
        return {
            tagName: 'div'
        };
    },

    getInitialState: function() {
        return {
            toggleState: this.props.initialState,
            loading: false,
            tagName: this.props.tagName || 'div'
        };
    },

    handleClick: function () {
        var newState = this.state.toggleState;
        this.setState({loading: true});

        fetch(decodeURI(this.props.url).replace(/{{value}}/, newState.toString()), safeCredentials({
            method: this.props[`${newState}_props`].method || 'PATCH'
        })).then((response) => {
            if (response.status === 201 || response.status === 304) {
                this.setState({toggleState: true});
            } else if (response.status === 204) {
                this.setState({toggleState: false});
            } else {
                throw 'ActiveToggle:33';
            }
            this.setState({loading: false});
        });
    },

    render: function () {
        var currentProps = this.props[`${this.state.toggleState}_props`];
        var label;
        if (this.props.label !== false) {
            label = <span className='icon-left'>{currentProps.label}</span>;
        }

        return (
            <this.state.tagName onClick={this.handleClick} className={this.state.loading ? 'is-loading' : ''}>
                <span className={`fa fa-${currentProps.icon}`}></span>
                {label}
            </this.state.tagName>
        )
    }
});

window.ActiveToggle = ActiveToggle;
