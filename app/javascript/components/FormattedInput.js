import React from 'react';
import Cleave from 'cleave.js/react';

export const FormattedInput = React.createClass({
    propTypes: {
        autoFocus: React.PropTypes.bool,
        className: React.PropTypes.string,
        name: React.PropTypes.string,
        options: React.PropTypes.object,
        value: React.PropTypes.string
    },

    getInitialState () {
        return {
            value: this.props.value
        }
    },

    handleChange (event) {
        this.setState({ value: event.target.rawValue });
    },

    render () {
        return (
            <span>
                <Cleave
                    autoFocus={this.props.autoFocus}
                    className={this.props.className}
                    name=""
                    onChange={this.handleChange}
                    options={this.props.options}
                    value={this.props.value}/>
                <input type="hidden" name={this.props.name} value={this.state.value}/>
            </span>
        );
    }
});

export default FormattedInput
