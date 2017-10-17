/* global Bugsnag, fetch */
import 'whatwg-fetch';
import React from 'react';

import Alert from '../Alert';
import {
    safeCredentials,
    json,
    statusSuccess,
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
        this.setState({ submittingVote: side });
        fetch(this.props.vote_url, safeCredentials({
            method: 'POST',
            body: JSON.stringify({
                vote: {
                    for: side
                }
            })
        })).then(statusSuccess)
            .then(json)
            .then(data => {
                if (typeof data !== 'undefined') {
                    this.setState(Object.assign({}, data.vote, { submittingVote: '', opinionForm: true }));
                }
            }).catch(e => {
                json(e)
                    .then(data => {
                        if (data.code === 'TERMS_NOT_ACCEPTED') {
                            window.modal.open(data.body);
                        }
                        else {
                            return Promise.reject();
                        }
                    }).catch(() => {
                        const message = errorMessageForStatus(e.status).fallback || I18n.t('errors.general');
                        new Alert(message, 'alert', true);
                        Bugsnag.notifyException(e);
                        throw e;
                    });
                this.setState({ submittingVote: '' });
            });
    }
};

export default VoteMixin;
