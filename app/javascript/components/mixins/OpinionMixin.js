/* global Bugsnag, fetch */
import Alert from '../Alert';
import React from 'react';
import I18n from 'i18n-js';
import {
    safeCredentials,
    json,
    statusSuccess,
    tryLogin,
    errorMessageForStatus
} from '../lib/helpers';

const OpinionMixin = {
    propTypes: {
        arguments: React.PropTypes.array,
        currentExplanation: React.PropTypes.object,
        selectedArguments: React.PropTypes.array
    },

    argumentChangeHandler (e) {
        switch (e.target.dataset.field) {
        case 'side':
            this.setState({ createArgument: Object.assign({}, this.state.createArgument, { side: e.target.dataset.value }) });
            break;
        case 'title':
            this.setState({ createArgument: Object.assign({}, this.state.createArgument, { title: e.target.value }) });
            break;
        case 'body':
            this.setState({ createArgument: Object.assign({}, this.state.createArgument, { body: e.target.value }) });
            break;
        }
    },

    argumentSelectionChangeHandler (e) {
        this.setState({ newSelectedArguments: e });
    },

    argumentHandler (e) {
        e.preventDefault();
        const { createArgument: { side, title, body } } = this.state;
        this.setState({ submitting: true });
        fetch(`${this.props.argumentUrl}.json`, safeCredentials({
            method: 'POST',
            body: JSON.stringify({
                argument: {
                    auto_vote: 'true',
                    content: body,
                    pro: side,
                    title
                }
            })
        })).then(statusSuccess, tryLogin)
            .then(json)
            .then(data => {
                if (typeof data !== 'undefined') {
                    const id = parseInt(data.data.id.split('/').pop());
                    const args = this.state.arguments.slice();
                    args.push({
                        displayName: data.data.attributes.name,
                        id,
                        key: `arguments_${id}`,
                        url: data.data.id,
                        side: data.data.attributes.pro ? 'pro' : 'con'
                    });
                    const selectedArguments = this.state.selectedArguments.slice();
                    selectedArguments.push(id);
                    const newSelectedArguments = this.state.newSelectedArguments.slice();
                    newSelectedArguments.push(id);
                    this.setState({
                        argumentForm: false,
                        arguments: args,
                        createArgument: {
                            side: undefined,
                            title: '',
                            body: ''
                        },
                        selectedArguments,
                        submitting: false,
                        newSelectedArguments
                    });
                }
            }).catch(er => {
                this.setState({ submitting: false });
                const message = errorMessageForStatus(er.status).fallback || I18n.t('errors.general');
                new Alert(message, 'alert', true);
                Bugsnag.notifyException(er);
                throw er;
            });
    },

    closeArgumentFormHandler () {
        this.setState({ argumentForm: false });
    },

    closeOpinionFormHandler () {
        this.setState({
            opinionForm: false
        });
    },

    explanationChangeHandler (e) {
        this.setState({ newExplanation: e.target.value });
    },

    handleCancelLogin (e) {
        e.preventDefault();
        this.setState({ loginStep: 'initial' });
    },

    handleLogin (e) {
        e.preventDefault();
        const { signupEmail, signupPassword } = this.state;
        this.setState({ submitting: true });
        fetch(`${this.props.oauthTokenUrl}.json`, safeCredentials({
            method: 'POST',
            body: JSON.stringify({
                email: signupEmail,
                password: signupPassword,
                grant_type: 'password',
                scope: 'user',
                r: window.location.href
            })
        })).then(statusSuccess)
            .then(json)
            .then(data => {
                if (typeof data !== 'undefined') {
                    window.location.hash = `${this.props.objectType}${this.props.objectId}`;
                    window.location.reload();
                }
            }).catch(er => {
                json(er)
                    .then(data => {
                        if (data.code === 'UNKNOWN_EMAIL') {
                            this.setState({ loginStep: 'register', errorMessage: data.message });
                            Promise.resolve(data);
                        } else if (data.code === 'WRONG_PASSWORD') {
                            this.setState({ loginStep: 'login', errorMessage: this.state.loginStep === 'initial' ? '' : data.message });
                            Promise.resolve(data);
                        } else {
                            Promise.reject();
                        }
                    }).catch(() => {
                        const message = errorMessageForStatus(er.status).fallback || I18n.t('errors.general');
                        new Alert(message, 'alert', true);
                        Bugsnag.notifyException(er);
                        throw er;
                    });
                this.setState({ submitting: false });
            });
    },

    handleRegistration (e) {
        e.preventDefault();
        const { signupEmail } = this.state;
        this.setState({ submitting: true });
        fetch(`${this.props.userRegistrationUrl}.json`, safeCredentials({
            method: 'POST',
            body: JSON.stringify({ accept_terms: true, user: { email: signupEmail, r: window.location.href } })
        })).then(statusSuccess)
            .then(json)
            .then(data => {
                if (typeof data !== 'undefined') {
                    window.location.hash = `${this.props.objectType}${this.props.objectId}`;
                    window.location.reload();
                }
            }).catch(er => {
                json(er)
                    .then(data => {
                        if (data.code === 'VALUE_TAKEN') {
                            this.setState({ loginStep: 'login', errorMessage: '' });
                        }
                    }).catch(() => {
                        const message = errorMessageForStatus(er.status).fallback || I18n.t('errors.general');
                        new Alert(message, 'alert', true);
                        Bugsnag.notifyException(er);
                        throw er;
                    });
                this.setState({ submitting: false });
            });
    },

    handleSignupEmailChange (e) {
        this.setState({ signupPassword: e.target.value });
    },

    handleShowAllArguments (e) {
        e.preventDefault();
        this.setState({ showAllArguments: true });
    },

    openArgumentFormHandler (e) {
        e.preventDefault();
        this.setState({
            argumentForm: true,
            createArgument: Object.assign({}, this.state.createArgument, { side: e.target.dataset.value })
        });
    },

    openOpinionFormHandler () {
        this.setState({ opinionForm: true });
    },

    opinionHandler (e) {
        e.preventDefault();
        const { currentVote, newExplanation, newSelectedArguments } = this.state;
        this.setState({ submitting: true });
        fetch(`${this.props.vote_url}.json`, safeCredentials({
            method: 'POST',
            body: JSON.stringify({
                vote: {
                    argument_ids: newSelectedArguments,
                    explanation: newExplanation,
                    for: currentVote
                }
            })
        })).then(statusSuccess)
            .then(json)
            .then(data => {
                if (typeof data !== 'undefined') {
                    this.setState(Object.assign({}, data.vote, {
                        opinionForm: false,
                        currentExplanation: { explanation: this.state.newExplanation, explained_at: new Date },
                        selectedArguments: this.state.newSelectedArguments,
                        submitting: false
                    }));
                }
            }).catch(er => {
                this.setState({ submitting: false });
                const message = errorMessageForStatus(er.status).fallback || I18n.t('errors.general');
                new Alert(message, 'alert', true);
                Bugsnag.notifyException(er);
                throw er;
            });
    },

    signupEmailChangeHandler (e) {
        this.setState({ signupEmail: e.target.value });
    }
};

export default OpinionMixin;
