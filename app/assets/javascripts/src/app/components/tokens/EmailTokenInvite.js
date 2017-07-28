import Alert from '../Alert';
import React from 'react';
import I18n from 'i18n-js';
import { safeCredentials, statusSuccess, json } from '../../lib/helpers';
import Select from 'react-select';
import TokenList from './TokenList';

export const EmailTokenInvite = React.createClass({
    propTypes: {
        createTokenUrl: React.PropTypes.string,
        currentActor: React.PropTypes.number,
        groupId: React.PropTypes.number,
        indexTokenUrl: React.PropTypes.string,
        managedProfiles: React.PropTypes.array,
        message: React.PropTypes.string
    },

    getInitialState () {
        return {
            currentActor: this.props.currentActor,
            invalidEmails: [],
            message: this.props.message,
            tokens: undefined,
            value: ''
        };
    },

    componentDidMount () {
        const { indexTokenUrl } = this.props;
        fetch(`${indexTokenUrl}/g/${this.props.groupId}`, safeCredentials())
            .then(statusSuccess)
            .then(json)
            .then(data => {
                this.setState({ tokens: data.data });
            });
    },

    handleEmailsChange (e) {
        const emails = this.stringToEmails(e.target.value);
        this.setState({
            invalidEmails: emails.filter(this.invalidEmail),
            value: e.target.value
        });
    },

    handleMessageChange (e) {
        this.setState({ message: e.target.value });
    },

    handleSubmit () {
        if (this.state.invalidEmails.length === 0) {
            this.createTokens();
        }
    },

    createTokens () {
        const emails = this.stringToEmails(this.state.value);
        const { createTokenUrl, groupId } = this.props;
        fetch(createTokenUrl,
            safeCredentials({
                method: 'POST',
                body: JSON.stringify({
                    data: {
                        type: 'emailTokenRequest',
                        attributes: {
                            addresses: emails,
                            group_id: groupId,
                            message: this.state.message,
                            actor_iri: this.state.currentActor,
                            send_mail: true
                        }
                    }
                })
            }))
            .then(statusSuccess)
            .then(json)
            .then(data => {
                new Alert(I18n.t('tokens.email.success'), 'success', true);
                this.setState({
                    tokens: this.state.tokens.concat(data.data),
                    value: ''
                });
            });
    },

    stringToEmails (string) {
        return string.split(/[\s,;]+/).filter(Boolean);
    },

    invalidEmail (email) {
        const re = /^\w+([\.-]?\w+)*(\+\w+)?@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return !re.test(email);
    },

    onRetract (token) {
        this.setState({
            tokens: this.state.tokens.filter(i => { return i.id !== token.id })
        });
    },

    valueRenderer (obj) {
        return (
            <div>
                <img className="Select-item-result-icon" height='25em' src={obj.image} width='25em'/>
                {obj.label}
            </div>
        );
    },

    onProfileChange (value) {
        this.setState({ currentActor: value.value })
    },

    render () {
        let errorMessage;
        if (this.state.value === '') {
            errorMessage = I18n.t('tokens.errors.no_emails');
        } else if (this.state.invalidEmails.length > 0) {
            errorMessage = I18n.t('tokens.errors.parsing', { emails: this.state.invalidEmails.join(', ') });
        }
        return (
            <div className="formtastic">
                <textarea
                    className="form-input-content"
                    name="emails"
                    onChange={this.handleEmailsChange}
                    placeholder={I18n.t('tokens.email.input_placeholder')}
                    value={this.state.value}/>
                <label>{I18n.t('tokens.labels.message')}</label>
                <textarea
                    className="form-input-content"
                    name="emails"
                    onChange={this.handleMessageChange}
                    placeholder={I18n.t('tokens.email.input_placeholder')}
                    value={this.state.message}/>
                <fieldset className="actions">
                    <span>{I18n.t('tokens.labels.sender_profile')}&nbsp;</span>
                    <Select
                        className="Select-profile"
                        clearable={false}
                        matchProp="any"
                        name='email-profile-id'
                        onChange={this.onProfileChange}
                        optionRenderer={this.valueRenderer}
                        options={this.props.managedProfiles}
                        placeholder="Select user"
                        value={this.state.currentActor}
                        valueRenderer={this.valueRenderer}/>
                    <button
                        data-title={errorMessage}
                        disabled={errorMessage !== undefined}
                        onClick={this.handleSubmit}
                        type="submit"
                        value="Submit"> {I18n.t('tokens.email.create')} </button>
                </fieldset>
                <legend><span>{I18n.t('tokens.email.pending')}</span></legend>
                <TokenList
                    columns={['email', 'createdAt']}
                    emptyString={I18n.t('tokens.email.empty')}
                    retractHandler={this.onRetract}
                    tokens={this.state.tokens}/>
            </div>
        );
    }
});
window.EmailTokenInvite = EmailTokenInvite;
