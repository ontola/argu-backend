/* global Bugsnag, fetch */
/**
 * Component to render an ArrayCheckbox
 * @class CheckboxGroup
 */

import React from 'react'
import I18n from 'i18n-js';
import { errorMessageForStatus, safeCredentials } from "./lib/helpers";
import Alert from "./Alert";

export const CheckboxGroup = React.createClass({
    propTypes: {
        childClass: React.PropTypes.string,
        inputOpts: React.PropTypes.object,
        onChange: React.PropTypes.func,
        options: React.PropTypes.array,
        value: React.PropTypes.array,
        wrapperClass: React.PropTypes.string
    },

    getInitialState () {
        return {
            loading: []
        }
    },

    addLoading (id) {
        if (this.state.loading.indexOf(id) === -1) {
            const loading = this.state.loading.slice();
            loading.push(id);
            this.setState({ loading });
        }
    },

    handleChange (event) {
        const side = event.target.dataset.side;
        const argumentId = parseInt(event.target.value);
        this.addLoading(argumentId);

        if (this.valueChecked(argumentId)) {
            if (!event.target.checked) {
                this.valueUncheck(side, argumentId);
            }
        } else {
            if (event.target.checked) {
                this.valueCheck(side, argumentId);
            }
        }
    },

    removeLoading (id) {
        if (this.state.loading.indexOf(id) >= 0) {
            const loading = this.state.loading.slice();
            const index = loading.indexOf(id);
            loading.splice(index, 1);
            this.setState({ loading });
        }
    },

    valueChecked (value) {
        return (this.props.value.indexOf(value) >= 0);
    },

    valueCheck (side, argumentId) {
        fetch(`/${side}/${argumentId}/votes`, safeCredentials({
            method: 'POST',
            body: JSON.stringify({
                vote: {
                    for: 'pro'
                }
            })
        })).then(response => {
            if (response.status >= 200 && response.status < 300 || response.status === 304 || response.status === 404) {
                this.removeLoading(argumentId);
                const result = this.props.value.slice();
                result.push(argumentId);
                this.props.onChange(result);
            } else {
                return Promise.reject(response);
            }
        }).catch(er => {
            this.removeLoading(argumentId);
            const message = errorMessageForStatus(er.status).fallback || I18n.t('errors.general');
            new Alert(message, 'alert', true);
            Bugsnag.notifyException(er);
            throw er;
        });
    },

    valueUncheck (side, argumentId) {
        fetch(`/${side}/${argumentId}/vote`, safeCredentials({
            method: 'DELETE',
            body: JSON.stringify({
                vote: {
                    for: 'pro'
                }
            })
        })).then(response => {
            if (response.status >= 200 && response.status < 300 || response.status === 304 || response.status === 404) {
                this.removeLoading(argumentId);
                const result = this.props.value.slice();
                const index = result.indexOf(argumentId);
                result.splice(index, 1);
                this.props.onChange(result);
            } else {
                return Promise.reject(response);
            }
        }).catch(er => {
            this.removeLoading(argumentId);
            const message = errorMessageForStatus(er.status).fallback || I18n.t('errors.general');
            new Alert(message, 'alert', true);
            Bugsnag.notifyException(er);
            throw er;
        });
    },

    renderInput (option) {
        if (this.state.loading.indexOf(option.value) >= 0) {
            return <div className="is-loading" style={{ fontSize: 'small', color: 'gray', left: '1.8em' }} />
        }
        return <input
            checked={this.valueChecked(option.value)}
            name={`checkbox[${option.value}]`}
            onChange={this.handleChange}
            type="checkbox"
            value={option.value}
            {...this.props.inputOpts}/>
    },

    renderOption (option) {
        const input = this.renderInput(option);
        return <label className={this.props.childClass} key={`argument-picker-${option.value}`}>
            {input}
            {option.label}
        </label>
    },

    render () {
        const { options, wrapperClass } = this.props;
        return (
            <div className={wrapperClass}>
                {options.map(this.renderOption)}
            </div>
        );
    }
});

export default CheckboxGroup;
