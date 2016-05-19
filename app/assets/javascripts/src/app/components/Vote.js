/**
 * Vote
 * @module Vote
 */

import React from 'react';
import { IntlMixin, FormattedMessage } from 'react-intl';
import VoteMixin from '../mixins/VoteMixin';

const HUNDRED_PERCENT = 100;

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
        actor: React.PropTypes.object,
        clickHandler: React.PropTypes.func,
        count: React.PropTypes.number,
        current: React.PropTypes.bool,
        objectId: React.PropTypes.number,
        side: React.PropTypes.string
    },

    iconForSide () {
        switch (this.props.side) {
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
        const { clickHandler, count, current, side } = this.props;

        let voteCountElem;
        if (count !== 0) {
            voteCountElem = <span className="vote-count">{count}</span>;
        }

        return (
            <li>
                <button type="button"
                        href={this.ifNoActor(`/m/${this.props.objectId}/v/${side}`)}
                        tabIndex='0'
                        data-method={this.ifNoActor('post')}
                        onClick={clickHandler}
                        rel="nofollow"
                        className={`btn-${side}`}
                        data-voted-on={current}
                        title={this.getIntlMessage(side)}>
                    <span className={`fa fa-${this.iconForSide()}`} />
                    <span className="vote-text">
                        <FormattedMessage message={this.getIntlMessage(side)} />
                    </span>
                    {voteCountElem}
                </button>
            </li>
        );
    }
});

export const VoteButtons = React.createClass({
    mixins: [IntlMixin, VoteMixin],

    propTypes: {
        actor: React.PropTypes.object,
        buttonsType: React.PropTypes.string,
        currentVote: React.PropTypes.string,
        distribution: React.PropTypes.object,
        objectId: React.PropTypes.number,
        objectType: React.PropTypes.string,
        percent: React.PropTypes.object
    },

    getInitialState () {
        return {
            currentVote: this.props.currentVote,
            distribution: this.props.distribution
        };
    },

    buttonsClassName () {
        switch (this.props.buttonsType) {
        case 'subtle':
            return 'btns-opinion--subtle';
        case 'big':
        default:
            return 'btns-opinion';
        }
    },

    render () {
        const voteButtons = ['pro', 'neutral' , 'con']
            .map((side, i) => {
                return <VoteButton actor={this.props.actor}
                                   clickHandler={this[`${side}Handler`]}
                                   count={this.state.distribution[side]}
                                   current={this.state.currentVote === side}
                                   key={i}
                                   objectId={this.props.objectId}
                                   side={side} />;
            });

        return (
            <ul className={this.buttonsClassName()} data-voted={(this.state.currentVote.length > 0 && this.state.currentVote !== 'abstain') || null}>
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
    propTypes: {
        percent: React.PropTypes.object,
        showResults: React.PropTypes.bool
    },

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

        if (this.props.showResults) {
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
