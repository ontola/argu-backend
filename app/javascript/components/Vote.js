/**
 * Vote
 * @module Vote
 */

import React from 'react';
import urltemplate from 'url-template';
import I18n from 'i18n-js';

import VoteMixin from './mixins/VoteMixin';

const HUNDRED_PERCENT = 100;
const voteURL = urltemplate.parse('/m{/id}/votes{?r}');

/**
 * Component for the POST-ing of a vote.
 * This component is not pure.
 * @class VoteButtons
 * @export VoteButtons
 * @memberof Vote
 */
export const VoteButton = React.createClass({
    propTypes: {
        actor: React.PropTypes.object,
        clickHandler: React.PropTypes.func,
        count: React.PropTypes.number,
        current: React.PropTypes.bool,
        disabled: React.PropTypes.bool,
        disabledMessage: React.PropTypes.string,
        objectId: React.PropTypes.number,
        r: React.PropTypes.string,
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

    render () {
        const { clickHandler, count, current, objectId: id, r, side } = this.props;
        const url = voteURL.expand({ id, side, r });

        let voteCountElem;
        if (count !== 0) {
            voteCountElem = <span className="vote-count">{count}</span>;
        }

        return (
            <li data-title={this.props.disabledMessage}>
                <a
                className={`btn-${side} ${this.props.disabled ? 'disabled' : 'enabled'}`}
                data-voted-on={current}
                href={url}
                onClick={clickHandler}
                rel="nofollow">
                    <span className={`fa fa-${this.iconForSide()}`} />
                    <span className="vote-text">
                        {I18n.t(`votes.type.${side}`)}
                    </span>
                    {voteCountElem}
                </a>
            </li>
        );
    }
});

export const VoteButtons = React.createClass({
    propTypes: {
        actor: React.PropTypes.object,
        buttonsType: React.PropTypes.string,
        currentVote: React.PropTypes.string,
        disabled: React.PropTypes.bool,
        disabledMessage: React.PropTypes.string,
        distribution: React.PropTypes.object,
        objectId: React.PropTypes.number,
        objectType: React.PropTypes.string,
        percent: React.PropTypes.object,
        r: React.PropTypes.string,
        vote_url: React.PropTypes.string
    },

    mixins: [VoteMixin],

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
        case 'bottom':
            return 'btns-opinion--bottom';
        case 'big':
        default:
            return 'btns-opinion';
        }
    },

    render () {
        const voteButtons = ['pro', 'neutral' , 'con']
            .map((side, i) => {
                return <VoteButton actor={this.props.actor}
                                   clickHandler={this.props[`${side}Handler`]}
                                   count={this.props.distribution[side]}
                                   current={this.props.currentVote === side}
                                   disabled={this.props.disabled}
                                   disabledMessage={this.props.disabledMessage}
                                   key={i}
                                   objectId={this.props.objectId}
                                   r={this.props.r}
                                   side={side} />;
            });

        return (
            <ul className={this.buttonsClassName()} data-voted={(this.props.currentVote.length > 0 && this.props.currentVote !== 'abstain') || null}>
                {voteButtons}
            </ul>);
    }
});

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
