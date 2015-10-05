import React from 'react/react-with-addons';
import { safeCredentials } from '../lib/helpers;

window.ActiveToggle = React.createClass({
    getDefaultProps: function() {
        "use strict";
        return {
            tagName: 'div'
        };
    },

    getInitialState: function() {
        "use strict";
        return {
            toggleState: this.props.initialState,
            loading: false,
            tagName: this.props.tagName || 'div'
        };
    },

    handleClick: function (picture) {
        "use strict";
        var newState = this.state.toggleState;
        this.setState({loading: true});

        fetch(decodeURI(this.props.url).replace(/{{value}}/, newState.toString()), safeCredentials({
            method: this.props[`${newState}_props`].method || 'PATCH'
        })).then((response) => {
            if (response.status == 201 || response.status == 304) {
                this.setState({toggleState: true});
            } else if (response.status == 204) {
                this.setState({toggleState: false});
            } else {
                console.log('An error occurred');
            }
            this.setState({loading: false});
        });
    },

    render: function () {
        var currentProps = this.props[`${this.state.toggleState}_props`];
        if (this.props.label !== false) {
            var label = <span className='icon-left'>{currentProps.label}</span>;
        }

        return (
            <this.state.tagName onClick={this.handleClick} className={this.state.loading ? 'is-loading' : ''}>
                <span className={`fa fa-${currentProps.icon}`}></span>
                {label}
            </this.state.tagName>
        )
    }
});

module.exports = ActiveToggle;
