/**
 * Component to render an ArrayCheckbox
 * @class CheckboxGroup
 */

import React from 'react'

export const CheckboxGroup = React.createClass({
    propTypes: {
        childClass: React.PropTypes.string,
        onChange: React.PropTypes.func,
        options: React.PropTypes.array,
        value: React.PropTypes.array,
        wrapperClass: React.PropTypes.string
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
        const result = this.props.value.slice();
        result.push(parseInt(event.target.value));
        this.props.onChange(result);
    },

    valueUncheck (event) {
        const result = this.props.value.slice();
        const index = result.indexOf(parseInt(event.target.value));
        result.splice(index, 1);
        this.props.onChange(result);
    },

    render () {
        const { options, wrapperClass, childClass } = this.props;
        return (
            <div className={wrapperClass}>
                {options.map(option => {
                    return (
                        <label className={childClass} key={`argument-picker-${option.value}`}>
                            <input
                                checked={this.valueChecked(option.value)}
                                name={`checkbox[${option.value}]`}
                                onChange={this.handleChange}
                                type="checkbox"
                                value={option.value}/>
                            {option.label}
                        </label>
                    )
                })}
            </div>
        );
    }
});

export default CheckboxGroup;
