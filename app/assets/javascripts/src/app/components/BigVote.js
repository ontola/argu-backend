/**
 * BigVote
 * @module BigVote
 */

import Alert from './Alert';
import React from 'react';
import { IntlMixin, FormattedMessage } from 'react-intl';
import {
    safeCredentials,
    json,
    statusSuccess,
    tryLogin,
    errorMessageForStatus
} from '../lib/helpers';

function createMembership(response) {
    return fetch(response.membership_url, safeCredentials({
        method: 'POST'
    })).then(statusSuccess);
}

function showNotifications (response) {
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
}

/**
 * Component for the POST-ing of a vote.
 * This component is not pure.
 * @class BigVoteButtons
 * @export BigVoteButtons
 * @memberof BigVote
 */
export const BigVoteButtons = React.createClass({
    mixins: [IntlMixin],

    getInitialState: function () {
        return {
            object_type: this.props.object_type,
            object_id: this.props.object_id,
            total_votes: this.props.total_votes,
            current_vote: this.props.current_vote,
            distribution: this.props.distribution,
            percent: this.props.percent
        };
    },

    handleNotAMember: function (response) {
        if (response.type === 'error' &&
            response.error_id === 'NOT_A_MEMBER') {
            return createMembership(response)
                .then(() => {
                    return this.vote(response.original_request.for);
                });
        } else {
            return Promise.resolve();
        }
    },

    ifNoActor: function (v) {
        return this.props.actor === null ? v : undefined;
    },

    ifActor: function (v) {
        return this.props.actor === null ? undefined : v;
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
    },

    vote2: function (side) {
        fetch(`${this.props.vote_url}/${side}.json`, safeCredentials({
            method: 'POST'
        })).then(json, tryLogin)
           .then(this.handleNotAMember)
           .then((data) => {
               if (typeof data !== 'undefined') {
                   this.setState(data.vote);
                   this.props.parentSetVote(data.vote);
               }
           }).catch((e) => {
            if (e.status === 403) {
                return e
                    .json()
                    .then(showNotifications)
            } else {
                const message = errorMessageForStatus(e.status).fallback || this.getIntlMessage('errors.general');
                new Alert(message, 'alert', true);
                Bugsnag.notifyException(e);
                throw e;
            }
           });
    },

    render: function () {
        return (
            <ul className="btns-opinion" data-voted={(this.state.current_vote.length > 0 && this.state.current_vote !== 'abstain') || null}>
                <li><a href={this.ifNoActor(`/m/${this.props.object_id}/v/pro`)} data-method={this.ifNoActor('post')} onClick={this.proHandler} rel="nofollow" className="btn-pro" data-voted-on={this.state.current_vote === 'pro' || null}>
                    <span className="fa fa-thumbs-up" />
                    <span className="icon-left">
                        <FormattedMessage message={this.getIntlMessage('pro')} />
                    </span>
                </a></li>
                <li><a href={this.ifNoActor(`/m/${this.props.object_id}/v/neutral`)} data-method={this.ifNoActor('post')} onClick={this.neutralHandler} rel="nofollow" className="btn-neutral" data-voted-on={this.state.current_vote === 'neutral' || null}>
                    <span className="fa fa-pause" />
                    <span className="icon-left"><FormattedMessage message={this.getIntlMessage('neutral')} /></span>
                </a></li>
                <li><a href={this.ifNoActor(`/m/${this.props.object_id}/v/con`)} data-method={this.ifNoActor('post')} onClick={this.conHandler} rel="nofollow" className="btn-con" data-voted-on={this.state.current_vote === 'con' || null}>
                    <span className="fa fa-thumbs-down" />
                    <span className="icon-left"><FormattedMessage message={this.getIntlMessage('con')} /></span>
                </a></li>
            </ul>);
    }
});
window.BigVoteButtons = BigVoteButtons;

export const BigVoteFormButton = React.createClass({

    render () {
        return (
            <a href={this.ifNoActor(`/m/${this.props.object_id}/v/pro`)} data-method="post" rel="nofollow" className="btn-pro" data-voted-on={this.state.current_vote === 'pro' || null}>
                <span className="fa fa-thumbs-up" />
                <span className="icon-left"><FormattedMessage message={this.getIntlMessage('pro')} /></span>
            </a>
        )
    }
});
window.BigVoteFormButton = BigVoteFormButton;

/**
 * Component to display voting results
 * @class BigVoteResults
 * @memberof BigVote
 */
export const BigVoteResults = React.createClass({
    voteWidth: function (side) {
        var supplemented_values = {
            pro: this.props.percent.pro < 5 ? 5 : this.props.percent.pro,
            neutral: this.props.percent.neutral < 5 ? 5 : this.props.percent.neutral,
            con: this.props.percent.con < 5 ? 5 : this.props.percent.con
        };
        var overflow = -100;
        for (var o in supplemented_values) {
            overflow += supplemented_values[o];
        }
        var width = supplemented_values[side] - (overflow * (this.props.percent[side] / 100));

        return {
            width: width + '%'
        };
    },

    render: function () {
        let results;

        if (this.props.show_results) {
            results = (
                    <ul className="progress-bar progress-bar-stacked">
                        <li style={this.voteWidth('pro')}><span className="btn-pro">{this.props.percent.pro + '%'}</span></li>
                        <li style={this.voteWidth('neutral')}><span className="btn-neutral">{this.props.percent.neutral + '%'}</span></li>
                        <li style={this.voteWidth('con')}><span className="btn-con">{this.props.percent.con + '%'}</span></li>
                    </ul>);
        } else {
            results = null;
        }

        return results;
    }
});
window.BigVoteResults = BigVoteResults;
