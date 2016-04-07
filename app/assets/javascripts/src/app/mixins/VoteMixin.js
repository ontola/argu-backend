import React from 'react';
import {
    safeCredentials,
    json,
    statusSuccess,
    tryLogin,
    errorMessageForStatus
} from '../lib/helpers';

const VoteMixin = {

    createMembership: function (response) {
        return fetch(response.membership_url, safeCredentials({
            method: 'POST'
        })).then(statusSuccess);
    },

    /*
    showNotifications: function (response) {
        if (typeof response !== 'undefined' &&
            typeof response.notifications !== 'undefined' &&
            response.notifications.constructor === Array) {
            for(let i = 0; i < response.notifications.length; i++) {
                const item = response.notifications[i];
                if (item.type === 'error') {
                    new Alert(item.message, item.type, true);
                }
            }
        }
        return Promise.resolve(response);
    },
    */

    handleNotAMember: function (response) {
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

    proHandler: function (e) {
        if (this.props.actor !== null) {
            e.preventDefault();
            this.vote('pro');
        }
    },
    neutralHandler: function (e) {
        if (this.props.actor !== null) {
            e.preventDefault();
            this.vote('neutral');
        }
    },
    conHandler: function (e) {
        if (this.props.actor !== null) {
            e.preventDefault();
            this.vote('con');
        }
    },

    vote: function (side) {
        fetch(`${this.props.vote_url}/${side}.json`, safeCredentials({
            method: 'POST'
        })).then(statusSuccess, tryLogin)
            .then(json)
            .then((data) => {
                if (typeof data !== 'undefined') {
                    this.setState(data.vote);
                    this.props.parentSetVote(data.vote);
                }
            }).catch((e) => {
            if (e.status === 403) {
                return e.json()
                    .then(this.handleNotAMember)
                    .then(() => {
                        this.vote(side);
                    });
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
