import Alert from '../Alert';
import React from 'react';
import I18n from 'i18n-js';
import { safeCredentials, statusSuccess, json } from '../lib/helpers';
import Select from 'react-select';
import TokenList from './TokenList';
import InvitedSelection from './InvitedSelection';
import 'whatwg-fetch';

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
            shouldLoadPage: false,
            message: this.props.message,
            submitting: false,
            values: []
        };
    },

    componentDidMount () {
        this.setState({ shouldLoadPage: true });
    },

    createTokens () {
        const { createTokenUrl, groupId } = this.props;
        const emails = this.state.values.map(email => { return email.value; });
        this.setState({ submitting: true });
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
            .then(() => {
                new Alert(I18n.t('tokens.email.success'), 'success', true);
                this.setState({ values: [], shouldLoadPage: true, submitting: false });
            });
    },

    handleInvitedChange (values) {
        this.setState({ values: this.state.values.concat(values) })
    },

    handleMessageChange (e) {
        this.setState({ message: e.target.value });
    },

    handlePageLoaded () {
        this.setState({ shouldLoadPage: false });
    },

    handleRemoveInvited (e) {
        e.preventDefault();
        this.setState({
            values: this.state.values.filter(i => { return i.value !== e.target.dataset.value })
        });
    },

    handleSubmit () {
        this.createTokens();
    },

    onProfileChange (value) {
        this.setState({ currentActor: value.value })
    },

    onRetract () {
        this.setState({ shouldLoadPage: true });
    },

    valueRenderer (obj) {
        return (
            <div>
                <img className="Select-item-result-icon" height='25em' src={obj.image} width='25em'/>
                {obj.label}
            </div>
        );
    },

    render () {
        let errorMessage;
        if (this.state.values.length === 0) {
            errorMessage = I18n.t('tokens.errors.no_receivers');
        }
        return (
            <div className={`formtastic ${this.state.submitting ? 'is-loading' : ''}`}>
                <InvitedSelection
                    handleInvitedChange={this.handleInvitedChange}
                    handleRemoveInvited={this.handleRemoveInvited}
                    values={this.state.values}/>
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
                <TokenList
                    columns={['invitee', 'createdAt', 'isRead']}
                    header={I18n.t('tokens.email.pending')}
                    onPageLoaded={this.handlePageLoaded}
                    shouldLoadPage={this.state.shouldLoadPage}
                    iri={`${this.props.indexTokenUrl}/g/${this.props.groupId}`}
                    retractHandler={this.onRetract}/>
            </div>
        );
    }
});

export default EmailTokenInvite;
