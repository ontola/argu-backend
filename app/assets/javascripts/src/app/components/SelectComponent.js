import React from 'react';
import Select from 'react-select';

export const SelectComponent = React.createClass({
    propTypes: {
        defaultValue: React.PropTypes.string
    },

    getInitialState () {
        return {
            value: this.props.defaultValue
        }
    },

    handleChange (value) {
        this.setState({ value });
    },

    render () {
        return (<Select value={this.state.value} onChange={this.handleChange} {...this.props}/>);
    }
});
export default SelectComponent
window.SelectComponent = SelectComponent;
