/*global Bugsnag*/
import Alert from '../Alert';
import React from 'react';
import I18n from 'i18n-js';
import { safeCredentials, statusSuccess, json } from '../lib/helpers';
import { AsyncCreatable } from 'react-select';
import 'whatwg-fetch';

const FETCH_TIMEOUT_AMOUNT = 500;

export const InvitedSelection = React.createClass({
    propTypes: {
        handleInvitedChange: React.PropTypes.func,
        handleRemoveInvited: React.PropTypes.func,
        values: React.PropTypes.array
    },

    getInitialState () {
        return {
            value: ''
        }
    },

    fetchUsers (input) {
        return fetch('/profiles.json', safeCredentials({
            method: 'POST',
            body: JSON.stringify({
                q: input,
                things: 'users'
            })
        }))
    },

    filterUsers (data) {
        return data.profiles.map(profile => {
            return {
                value: profile.shortname,
                label: `${profile.name} (${profile.shortname})`,
                image: profile.profile_photo.avatar.url
            };
        });
    },

    handleChange (value) {
        if (this.props.values.map(v => { return v.value }).indexOf(value.value) === -1) {
            let values = [];
            if (this.valueHasMultipleEmails(value.value)) {
                values = this.stringToEmails(value.value).map (v => {
                    return this.newOptionCreator({ label: v });
                });
            } else {
                values = [value];
            }
            this.props.handleInvitedChange(values);
        }
    },

    invalidEmail (email) {
        const re = /^[a-zA-Z0-9.!#$%&’*+\/=?^_`{|}~-]+@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return !re.test(email);
    },

    isValidNewOption (value) {
        return (value.label !== undefined && this.valueHasEmail(value.label));
    },

    loadOptions (input, callback) {
        if (typeof input !== 'string') {
            return null;
        }
        input = input.toLowerCase();
        if (!input.length || this.valueHasEmail(input)) {
            return callback(null, {
                complete: false
            });
        } else {
            window.clearTimeout(this.currentFetchTimeout);
            this.currentFetchTimeout = window.setTimeout(() => {
                this.fetchUsers(input.toLowerCase())
                    .then(statusSuccess)
                    .then(json)
                    .then(data => {
                        callback(null, { options: this.filterUsers(data, input), complete: false });
                    }).catch(e => {
                        Alert('Server error occured, please try again later', 'alert', true);
                        Bugsnag.notifyException(e);
                        callback();
                    });
            }, FETCH_TIMEOUT_AMOUNT);
        }
    },

    newOptionCreator (option) {
        if (this.valueIsValid(option.label)) {
            return {
                label: option.label,
                value: option.label
            }
        } else {
            return {
                disabled: true,
                label: I18n.t('tokens.email.has_invalid'),
                value: option.label
            }
        }
    },

    promptTextCreator (label) {
        return label;
    },

    selectionRenderer (obj) {
        const img = (obj.image === undefined) ? <span/> : <img className="Select-item-result-icon" height='25em' src={obj.image} width='25em'/>
        return (
            <div>
                {img}
                {obj.label}
                <a href="#" onClick={this.props.handleRemoveInvited}><span className="fa fa-close" data-value={obj.value} /></a>
            </div>
        );
    },

    shouldKeyDownEventCreateNewOption () {
        return false;
    },

    stringToEmails (string) {
        return string.split(/[\s,;]+/).filter(Boolean);
    },

    valueHasEmail (value) {
        return value.indexOf('@') !== -1
    },

    valueHasMultipleEmails (value) {
        return this.valueHasEmail(value) && /[\s,;]/.test(value);
    },

    valueIsValid(value) {
        if (value === undefined) {
            return false;
        }
        if (this.valueHasMultipleEmails(value)) {
            return this.stringToEmails(value).filter(this.invalidEmail).length === 0;
        } else {
            return !this.invalidEmail(value);
        }
    },

    valueRenderer (obj) {
        const img = (obj.image === undefined) ? <span/> : <img className="Select-item-result-icon" height='25em' src={obj.image} width='25em'/>
        return (
            <div>
                {img}
                {obj.label}
            </div>
        );
    },

    isOptionUnique () {
        return true;
    },

    render () {
        const currentValues = this.props.values.map(value => {
            return <div className="invite-selection" key={value.value}>{this.selectionRenderer(value)}</div>;
        });

        return (
            <div className="select-users-and-emails">
                <AsyncCreatable
                    clearable={false}
                    isOptionUnique={this.isOptionUnique}
                    isValidNewOption={this.isValidNewOption}
                    loadOptions={this.loadOptions}
                    newOptionCreator={this.newOptionCreator}
                    onChange={this.handleChange}
                    optionRenderer={this.valueRenderer}
                    placeholder={I18n.t('tokens.email.placeholder')}
                    promptTextCreator={this.promptTextCreator}
                    shouldKeyDownEventCreateNewOption={this.shouldKeyDownEventCreateNewOption}
                    value={this.state.value}/>
                <div>{currentValues}</div>
            </div>
        );
    }
});

export default InvitedSelection;
