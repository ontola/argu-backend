import Alert from './Alert';
import React from 'react';
import I18n from 'i18n-js';
import { safeCredentials, statusSuccess, json } from '../lib/helpers';

export const EmailTokenInvite = React.createClass({
    propTypes: {
        createTokenUrl: React.PropTypes.string,
        groupId: React.PropTypes.number,
        indexTokenUrl: React.PropTypes.string
    },

    getInitialState () {
        return {
            value: '',
            tokens: undefined
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

    handleChange (e) {
        this.setState({ value: e.target.value });
    },

    handleSubmit () {
        const emails = this.stringToEmails(this.state.value);
        if (emails.every(this.validateEmail)) {
            this.createTokens();
        } else {
            new Alert(I18n.t('tokens.errors.parsing'), 'alert', true);
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
                            group_id: groupId,
                            addresses: emails,
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
        return string.split(/[\s,;]+/);
    },

    validateEmail (email) {
        const re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return re.test(email);
    },

    onRetract (token) {
        this.setState({
            tokens: this.state.tokens.filter(i => { return i.id !== token.id })
        });
    },

    render () {
        return (
            <div className="formtastic">
                <InvitationList
                    retractHandler={this.onRetract}
                    tokens={this.state.tokens}/>
                <textarea
                    className="form-input-content"
                    name="emails"
                    onChange={this.handleChange}
                    placeholder={I18n.t('tokens.email.input_placeholder')}
                    value={this.state.value}/>
                <fieldset className="actions">
                    <button
                        onClick={this.handleSubmit}
                        type="submit"
                        value="Submit"> {I18n.t('tokens.email.create')} </button>
                </fieldset>

            </div>
        );
    }
});
window.EmailTokenInvite = EmailTokenInvite;

export const InvitationList = React.createClass({
    propTypes: {
        retractHandler: React.PropTypes.func,
        tokens: React.PropTypes.array
    },

    tbody () {
        const { retractHandler, tokens } = this.props;
        if (tokens === undefined) {
            return <tr><td>{I18n.t('tokens.loading')}</td></tr>;
        } else if (tokens.length === 0) {
            return <tr><td>{I18n.t('tokens.email.empty')}</td></tr>;
        } else {
            return tokens.map(token => {
                return <Invitation key={token.id} retractHandler={retractHandler} token={token}/>;
            });
        }
    },

    render () {
        return (
            <table>
                <thead>
                <tr>
                    <td>{I18n.t('tokens.labels.email')}</td>
                    <td>{I18n.t('tokens.labels.invited_at')}</td>
                    <td></td>
                </tr>
                </thead>
                <tbody>
                {this.tbody()}
                </tbody>
            </table>
        );
    }
});
window.InvitationList = InvitationList;

export const Invitation = React.createClass({
    propTypes: {
        retractHandler: React.PropTypes.func,
        token: React.PropTypes.object
    },

    handleRetract () {
        if (window.confirm(I18n.t('tokens.retract.confirm')) === true) {
            fetch(this.props.token.links.self,
                safeCredentials({
                    method: 'DELETE'
                }))
                .then(statusSuccess)
                .then(this.props.retractHandler(this.props.token));
        }
    },

    render () {
        const { attributes } = this.props.token;
        return (<tr>
            <td>
                {attributes.email}
                </td>
            <td>
                {attributes.createdAt}
                </td>
            <td>
                <a href='#' onClick={this.handleRetract}>{I18n.t('tokens.retract.button')}</a>
            </td>
        </tr>)
    }
});
