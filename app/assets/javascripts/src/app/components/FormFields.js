/**
 * FormFields
 * @module FormFields
 */

import React, { Component, PropTypes } from 'react'

/**
 * Component to render an ArrayCheckbox
 * @class ArrayCheckbox
 * @memberof FormFields
 */
export const CheckboxGroup = React.createClass({
    propTypes: {
        wrapperClass: React.PropTypes.string,
        childClass: React.PropTypes.string,
        options: React.PropTypes.array,
        value: React.PropTypes.array,
        onChange: React.PropTypes.func
    },

    handleChange (event) {
        if (this.valueChecked(parseInt(event.target.value))) {
            if (!event.target.checked) {
                this.valueUncheck(event);
            }
        } else {
            if (event.target.checked) {
                this.valueCheck(event);
            }
        }
    },

    valueChecked (value) {
        return (this.props.value.indexOf(value) >= 0);
    },

    valueCheck (event) {
        const result = this.props.value;
        result.push(parseInt(event.target.value));
        this.props.onChange(result);
    },

    valueUncheck (event) {
        const result = this.props.value;
        const index = result.indexOf(event.target.value);
        result.splice(index, 1);
        this.props.onChange(result);
    },

    render () {
        const { options, wrapperClass, childClass } = this.props;
        return (
            <div className={wrapperClass}>
                {options.map(option => <label className={childClass}>
                    <input
                        name={`checkbox[${option.value}]`}
                        type="checkbox"
                        checked={this.valueChecked(option.value)}
                        value={option.value}
                        onChange={this.handleChange}
                    />
                    {option.label}
                </label>)}
            </div>
        );
    }
});
window.CheckboxGroup = CheckboxGroup;

