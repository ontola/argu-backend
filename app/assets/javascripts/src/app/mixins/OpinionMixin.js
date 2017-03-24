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
        this.setState({ newSelectedArguments: e });
    },

    closeOpinionFormHandler () {
        this.setState({
            opinionForm: false
        });
    },

    explanationChangeHandler (e) {
        this.setState({ newExplanation: e.target.value });
    },

    openOpinionFormHandler () {
        this.setState({ opinionForm: true });
    },

    opinionHandler (e) {
        e.preventDefault();
        const { currentVote, newExplanation, newSelectedArguments } = this.state;
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
                    this.setState(Object.assign({}, data.vote, { opinionForm: false, currentExplanation: { explanation: this.state.newExplanation }, selectedArguments: this.state.newSelectedArguments }));
                }
            }).catch(er => {
                if (er.status === 403) {
                    return er.json()
                        .then(this.handleNotAMember)
                } else {
                    const message = errorMessageForStatus(er.status).fallback || this.getIntlMessage('errors.general');
                    new Alert(message, 'alert', true);
                    Bugsnag.notifyException(er);
                    throw er;
                }
            });
    }
};

export default OpinionMixin;
window.OpinionMixin = OpinionMixin;
