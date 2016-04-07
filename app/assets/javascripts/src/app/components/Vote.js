/**
 * Vote
 * @module Vote
 */

import Alert from './Alert';
import React from 'react';
import { IntlMixin, FormattedMessage } from 'react-intl';
import VoteMixin from '../mixins/VoteMixin';
import {
    safeCredentials,
    json,
    statusSuccess,
    tryLogin,
    errorMessageForStatus
} from '../lib/helpers';

const HUNDRED_PERCENT = 100;

function createMembership(response) {
    return fetch(response.membership_url, safeCredentials({
        method: 'POST'
    })).then(statusSuccess);
}

function showNotifications (response) {
    if (typeof response !== 'undefined' &&
        typeof response.notifications !== 'undefined' &&
        response.notifications.constructor === Array) {
        for (let i = 0; i < response.notifications.length; i++) {
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
 * @class VoteButtons
 * @export VoteButtons
 * @memberof Vote
 */
export const VoteButtons = React.createClass({
    mixins: [IntlMixin, VoteMixin],

    getInitialState () {
        return {
            object_type: this.props.objectType,
            object_id: this.props.object_id,
            total_votes: this.props.total_votes,
            current_vote: this.props.current_vote,
            distribution: this.props.distribution,
            percent: this.props.percent
        };
    },

    buttonsClassName: function () {
        switch(this.props.buttonsType) {
            case 'subtle':
                return 'btns-opinion--subtle';
            case 'big':
            default:
                return 'btns-opinion';
        }
    },

    render () {
        return (
            <ul className={this.buttonsClassName} data-voted={(this.state.current_vote.length > 0 && this.state.current_vote !== 'abstain') || null}>
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
window.VoteButtons = VoteButtons;

export const VoteFormButton = React.createClass({

    render () {
        return (
            <a href={this.ifNoActor(`/m/${this.props.object_id}/v/pro`)} data-method="post" rel="nofollow" className="btn-pro" data-voted-on={this.state.current_vote === 'pro' || null}>
                <span className="fa fa-thumbs-up" />
                <span className="icon-left"><FormattedMessage message={this.getIntlMessage('pro')} /></span>
            </a>
        )
    }
});
window.VoteFormButton = VoteFormButton;

const LOWER_DISPLAY_LIMIT = 5;

/**
 * Component to display voting results
 * @class VoteResults
 * @memberof Vote
 */
export const VoteResults = React.createClass({
    voteWidth (side) {
        const supplementedValues = {
            pro: this.props.percent.pro < LOWER_DISPLAY_LIMIT ? LOWER_DISPLAY_LIMIT : this.props.percent.pro,
            neutral: this.props.percent.neutral < LOWER_DISPLAY_LIMIT ? LOWER_DISPLAY_LIMIT : this.props.percent.neutral,
            con: this.props.percent.con < LOWER_DISPLAY_LIMIT ? LOWER_DISPLAY_LIMIT : this.props.percent.con
        };
        let overflow = -100;
        for (const o in supplementedValues) {
            overflow += supplementedValues[o];
        }

        const width = supplementedValues[side] - (overflow * (this.props.percent[side] / HUNDRED_PERCENT));

        return {
            width: width + '%'
        };
    },

    render () {
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
window.VoteResults = VoteResults;
