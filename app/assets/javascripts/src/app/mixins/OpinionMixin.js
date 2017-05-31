/* global Bugsnag, fetch */
import Alert from '../components/Alert';
import React from 'react';
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
                const message = errorMessageForStatus(er.status).fallback || this.getIntlMessage('errors.general');
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
        })).then(statusSuccess, tryLogin)
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
                const message = errorMessageForStatus(er.status).fallback || this.getIntlMessage('errors.general');
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
window.OpinionMixin = OpinionMixin;
