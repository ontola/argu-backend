/* global Bugsnag, fetch */
import 'whatwg-fetch';
import React from 'react';

import Alert from '../Alert';
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
                const message = errorMessageForStatus(e.status).fallback || I18n.t('errors.general');
                new Alert(message, 'alert', true);
                Bugsnag.notifyException(e);
                throw e;
            });
    }
};

export default VoteMixin;
