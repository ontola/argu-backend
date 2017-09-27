import React from 'react';
import I18n from 'i18n-js';
import Select from 'react-select';

import Alert from './Alert';
import { safeCredentials, statusSuccess, json } from './lib/helpers';

const MIN_NAME_LENGTH = 3;

export const GroupForm = React.createClass({
    propTypes: {
        createGroupUrl: React.PropTypes.number,
        forumEdge: React.PropTypes.number,
        forumName: React.PropTypes.string,
        forumNames: React.PropTypes.string,
        onCreate: React.PropTypes.func,
        pageEdge: React.PropTypes.number,
        roles: React.PropTypes.array
    },

    getInitialState () {
        return {
            name: '',
            nameSingular: '',
            currentRole: 'member',
            currentEdge: this.props.forumEdge
        };
    },

    handleCreateGroup () {
        fetch(this.props.createGroupUrl,
            safeCredentials({
                method: 'POST',
                body: JSON.stringify({
                    group: {
                        name: this.state.name,
                        name_singular: this.state.nameSingular,
                        grants_attributes: {
                            0: {
                                edge_id: this.state.currentEdge,
                                role: this.state.currentRole
                            }
                        }
                    }
                })
            }))
            .then(statusSuccess)
            .then(json)
            .then(body => {
                const id = parseInt(body.data.id.split('/').pop());
                const label = `${this.state.name} (${I18n.t('roles.may')} ${I18n.t(`roles.types.${this.state.currentRole}`)})`;
                this.props.onCreate(id, label)
            }).catch(e => {
                json(e).then(body => {
                    const errorMessage = Object
                                            .keys(body)
                                            .map(key => { return `${key.charAt(0).toUpperCase()}${key.slice(1)} ${body[key]}`; })
                                            .join('. ');
                    new Alert(errorMessage, 'alert', true);
                })
            });
    },

    handleSelectForum () {
        this.setState({ currentEdge: this.props.forumEdge });
    },

    handleSelectPage () {
        this.setState({ currentEdge: this.props.pageEdge });
    },

    handleNameChange (e) {
        this.setState({ name: e.target.value });
    },

    handleNameSingularChange (e) {
        this.setState({ nameSingular: e.target.value });
    },

    handleRoleChange (value) {
        this.setState({ currentRole: value.value });
    },

    render () {
        const disabled = (this.state.name.length < MIN_NAME_LENGTH || this.state.nameSingular.length < MIN_NAME_LENGTH);
        return (
            <div className="form-small form-padded">
                <label>{I18n.t('formtastic.labels.group.name')}</label>
                <input
                    className="form-input-content"
                    name="group-name"
                    onChange={this.handleNameChange}
                    placeholder={I18n.t('formtastic.placeholders.group.name')}
                    type="text"
                    value={this.state.name}/>
                <label>{I18n.t('formtastic.labels.group.name_singular')}</label>
                <input
                    className="form-input-content"
                    name="group-name-singular"
                    onChange={this.handleNameSingularChange}
                    placeholder={I18n.t('formtastic.placeholders.group.name_singular')}
                    type="text"
                    value={this.state.nameSingular}/>
                <label>{I18n.t('roles.label')}</label>
                <Select
                    clearable={false}
                    onChange={this.handleRoleChange}
                    options={this.props.roles}
                    value={this.state.currentRole}/>
                <label>
                    <input type="radio"
                           value={this.props.forumEdge}
                           checked={this.state.currentEdge === this.props.forumEdge}
                           onChange={this.handleSelectForum}
                           style={{ width: 'initial!important' }}/>
                    {I18n.t('roles.in_current_forum', { forum: this.props.forumName })}
                </label>
                <label>
                    <input type="radio"
                           value={this.props.pageEdge}
                           checked={this.state.currentEdge === this.props.pageEdge}
                           onChange={this.handleSelectPage}
                           style={{ width: 'initial!important' }}/>
                    <span className="icon-right">{I18n.t('roles.in_all_forums')}</span>
                    <span data-title={this.props.forumNames}>
                        <span className="fa fa-warning"/>
                    </span>
                </label>
                <button
                    className={`${disabled ? 'is-loading' : ''}`}
                    disabled={disabled}
                    onClick={this.handleCreateGroup}
                    type="submit"
                    value="Submit">{I18n.t('tokens.discussion.group.create')}</button>
            </div>
        );
    }
});
export default GroupForm;
