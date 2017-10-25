/* global Bugsnag */
import React from 'react';
import I18n from 'i18n-js';
import Select from 'react-select';

import Alert from '../Alert';
import GroupForm from '../GroupForm';
import { modal } from '../../../assets/javascripts/application/modal';
import { errorMessageForStatus, safeCredentials, statusSuccess, json } from '../lib/helpers';

import InvitedSelection from './InvitedSelection';

export const DiscussionInvite = React.createClass({
    propTypes: {
        createGroupUrl: React.PropTypes.string,
        createTokenUrl: React.PropTypes.string,
        currentActor: React.PropTypes.number,
        forumEdge: React.PropTypes.number,
        forumName: React.PropTypes.string,
        forumNames: React.PropTypes.string,
        groupEdge: React.PropTypes.array,
        groups: React.PropTypes.array,
        indexTokenUrl: React.PropTypes.string,
        managedProfiles: React.PropTypes.array,
        message: React.PropTypes.string,
        pageEdge: React.PropTypes.number,
        resource: React.PropTypes.string,
        roles: React.PropTypes.array
    },

    getInitialState () {
        return {
            currentActor: this.props.currentActor,
            currentGroup: null,
            groups: this.props.groups,
            message: this.props.message,
            values: []
        };
    },

    createTokens () {
        const { createTokenUrl } = this.props;
        const emails = this.state.values.map(email => { return email.value; });
        fetch(createTokenUrl,
            safeCredentials({
                method: 'POST',
                body: JSON.stringify({
                    data: {
                        type: 'emailTokenRequest',
                        attributes: {
                            actor_iri: this.state.currentActor,
                            addresses: emails,
                            group_id: this.state.currentGroup,
                            message: this.state.message,
                            redirect_url: this.props.resource,
                            send_mail: true
                        }
                    }
                })
            }))
            .then(statusSuccess)
            .then(json)
            .then(() => {
                new Alert(I18n.t('tokens.email.success'), 'success', true);
                modal.close();
            }).catch(e => {
                if (e.status === 504) {
                    new Alert(I18n.t('tokens.email.processing'), 'success', true);
                    modal.close();
                } else {
                    const message = errorMessageForStatus(e.status).fallback || I18n.t('errors.general');
                    new Alert(message, 'alert', true);
                    Bugsnag.notifyException(e);
                    throw e;
                }
            });
    },

    handleGroupCreate (value, label) {
        const groups = this.state.groups.slice(0);
        groups.unshift({ value, label });
        this.setState({ groups, currentGroup: value });
    },

    handleInvitedChange (values) {
        this.setState({ values: this.state.values.concat(values) })
    },

    handleMessageChange (e) {
        this.setState({ message: e.target.value });
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

    onGroupChange (value) {
        this.setState({ currentGroup: value.value })
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

    render () {
        let errorMessage, groupForm;
        if (this.state.values.length === 0) {
            errorMessage = I18n.t('tokens.errors.no_receivers');
        } else if (this.state.currentGroup === undefined || this.state.currentGroup === null || this.state.currentGroup === -1) {
            errorMessage = I18n.t('tokens.discussion.group.placeholder');
        }
        if (this.state.currentGroup === -1) {
            groupForm = <GroupForm createGroupUrl={this.props.createGroupUrl}
                                   currentEdge={this.props.groupEdge}
                                   forumEdge={this.props.forumEdge}
                                   forumName={this.props.forumName}
                                   forumNames={this.props.forumNames}
                                   onCreate={this.handleGroupCreate}
                                   pageEdge={this.props.pageEdge}
                                   roles={this.props.roles}/>;
        }
        return (
            <div className="formtastic formtastic--full-width">
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
                <label>{I18n.t('tokens.discussion.group.label')}</label>
                <Select
                    className="Select-group"
                    clearable={false}
                    matchProp="any"
                    onChange={this.onGroupChange}
                    optionRenderer={this.valueRenderer}
                    options={this.state.groups}
                    placeholder={I18n.t('tokens.discussion.group.placeholder')}
                    value={this.state.currentGroup}
                    valueRenderer={this.valueRenderer}/>
                {groupForm}
                <fieldset className="actions">
                    <span>{I18n.t('tokens.labels.sender_profile')}&nbsp;</span>
                    <Select
                        className="Select-profile"
                        clearable={false}
                        matchProp="any"
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
            </div>
        );
    }
});

export default DiscussionInvite;
