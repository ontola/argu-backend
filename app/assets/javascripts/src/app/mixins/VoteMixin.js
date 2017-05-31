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

const VoteMixin = {
    propTypes: {
        actor: React.PropTypes.object,
        vote_url: React.PropTypes.string.isRequired
    },

    proHandler (e) {
        e.preventDefault();
        if (!this.props.disabled) {
            this.vote('pro');
        }
    },
    neutralHandler (e) {
        e.preventDefault();
        if (!this.props.disabled) {
            this.vote('neutral');
        }
    },
    conHandler (e) {
        e.preventDefault();
        if (!this.props.disabled) {
            this.vote('con');
        }
    },

    vote (side) {
        fetch(`${this.props.vote_url}.json`, safeCredentials({
            method: 'POST',
            body: JSON.stringify({
                vote: {
                    for: side
                }
            })
        })).then(statusSuccess, tryLogin)
            .then(json)
            .then(data => {
                if (typeof data !== 'undefined') {
                    this.setState(Object.assign({}, data.vote, { opinionForm: true }));
                }
            }).catch(e => {
                const message = errorMessageForStatus(e.status).fallback || this.getIntlMessage('errors.general');
                new Alert(message, 'alert', true);
                Bugsnag.notifyException(e);
                throw e;
            });
    }
};

export default VoteMixin;
window.VoteMixin = VoteMixin;
