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
export const VoteButton = React.createClass({
    mixins: [IntlMixin],

    propTypes: {
        side: React.PropTypes.string,
        count: React.PropTypes.number,
        current: React.PropTypes.bool,
        object_id: React.PropTypes.number,
        clickHandler: React.PropTypes.func
    },

    iconForSide () {
        switch(this.props.side) {
            case 'pro':
                return 'thumbs-up';
            case 'neutral':
                return 'pause';
            case 'con':
                return 'thumbs-down';
        }
    },

    ifNoActor (v) {
        return this.props.actor === null ? v : undefined;
    },

    ifActor (v) {
        return this.props.actor === null ? undefined : v;
    },

    render () {
        let { clickHandler, count, current, side } = this.props;

        let voteCountElem;
        if (count != 0) {
            voteCountElem = <span className="vote-count">{count}</span>;
        }

        return (
            <li><a href={this.ifNoActor(`/m/${this.props.object_id}/v/${side}`)} data-method={this.ifNoActor('post')}
                   onClick={clickHandler} rel="nofollow" className={`btn-${side}`} data-voted-on={current}>
                <span className={`fa fa-${this.iconForSide()}`} />
                    <span className="icon-left">
                        <span className="vote-text">
                            <FormattedMessage message={this.getIntlMessage(side)} />
                        </span>
                        {voteCountElem}
                    </span>
            </a></li>
        );
    }
});

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
        let voteButtons = ['pro', 'neutral' , 'con']
            .map((side, i) => {
                return <VoteButton key={i}
                                   side={side}
                                   count={this.state.distribution[side]}
                                   current={this.state.current_vote === side}
                                   object_id={this.object_id}
                                   clickHandler={this[`${side}Handler`]} />;
            });

        return (
            <ul className={this.buttonsClassName()} data-voted={(this.state.current_vote.length > 0 && this.state.current_vote !== 'abstain') || null}>
                {voteButtons}
            </ul>);
    }
});
window.VoteButtons = VoteButtons;

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
