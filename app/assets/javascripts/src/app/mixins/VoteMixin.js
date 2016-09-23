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

    createMembership (response) {
        return fetch(response.links.create_membership.href, safeCredentials({
            method: 'POST'
        })).then(statusSuccess);
    },

    handleNotAMember (response) {
        if (response.type === 'error' &&
            response.error_id === 'NOT_A_MEMBER') {
            return this.createMembership(response)
                .then(() => {
                    return this.vote(response.original_request.for);
                });
        } else {
            return Promise.resolve();
        }
    },

    proHandler (e) {
        if (this.props.actor !== null) {
            e.preventDefault();
            this.vote('pro');
        }
    },
    neutralHandler (e) {
        if (this.props.actor !== null) {
            e.preventDefault();
            this.vote('neutral');
        }
    },
    conHandler (e) {
        if (this.props.actor !== null) {
            e.preventDefault();
            this.vote('con');
        }
    },

    vote (side) {
        fetch(`${this.props.vote_url}/${side}.json`, safeCredentials({
            method: 'POST'
        })).then(statusSuccess, tryLogin)
            .then(json)
            .then(data => {
                if (typeof data !== 'undefined') {
                    this.setState(data.vote);
                }
            }).catch(e => {
                if (e.status === 403) {
                    return e.json()
                        .then(this.handleNotAMember)
                } else {
                    const message = errorMessageForStatus(e.status).fallback || this.getIntlMessage('errors.general');
                    new Alert(message, 'alert', true);
                    Bugsnag.notifyException(e);
                    throw e;
                }
            });
    }
};

export default VoteMixin;
window.VoteMixin = VoteMixin;
