/**
 * Vote
 * @module Vote
 */

import React from 'react';
import urltemplate from 'url-template';
import I18n from 'i18n-js';

import VoteMixin from './mixins/VoteMixin';

const HUNDRED_PERCENT = 100;
const voteURL = urltemplate.parse('{+vote_path}/new{?r}');

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
        hasExplanation: React.PropTypes.bool,
        objectId: React.PropTypes.number,
        r: React.PropTypes.string,
        side: React.PropTypes.string,
        submittingVote: React.PropTypes.string,
        vote_path: React.PropTypes.string
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
        const { clickHandler, count, current, r, side, vote_path } = this.props;
        const url = voteURL.expand({ vote_path, r });

        let voteCountElem;
        if (count !== 0) {
            voteCountElem = <span className="vote-count">{count}</span>;
        }

        return (
            <li data-title={this.props.disabledMessage}>
                <a
                className={`btn-${side} ${this.props.disabled ? 'disabled' : 'enabled'}${this.props.submittingVote === this.props.side ? ' is-loading' : ''}`}
                data-voted-on={current}
                href={url}
                onClick={clickHandler}
                rel="nofollow">
                    <span className={`fa fa-${this.iconForSide()}`} />
                    <span className="vote-text">
                        {I18n.t(`votes.instance_type.${side}`)}
                    </span>
                    {voteCountElem}
                    {this.props.hasExplanation && current &&
                      <span className={'fa fa-commenting-o icon-left'} />
                    }
                </a>
            </li>
        );
    }
});

export const VoteButtons = React.createClass({
    propTypes: {
        actor: React.PropTypes.object,
        buttonsType: React.PropTypes.string,
        currentVote: React.PropTypes.object,
        disabled: React.PropTypes.bool,
        disabledMessage: React.PropTypes.string,
        distribution: React.PropTypes.object,
        objectId: React.PropTypes.number,
        objectType: React.PropTypes.string,
        percent: React.PropTypes.object,
        r: React.PropTypes.string,
        submittingVote: React.PropTypes.string,
        vote_path: React.PropTypes.string
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
                                   current={this.props.currentVote.side === side}
                                   hasExplanation={this.props.currentVote.comment && !!this.props.currentVote.comment.id}
                                   disabled={this.props.disabled}
                                   disabledMessage={this.props.disabledMessage}
                                   key={i}
                                   objectId={this.props.objectId}
                                   r={this.props.r}
                                   side={side}
                                   submittingVote={this.props.submittingVote}
                                   vote_path={this.props.vote_path}/>;
            });

        return (
            <ul className={this.buttonsClassName()} data-voted={(typeof this.props.currentVote.id !== 'undefined' && this.props.currentVote.side !== 'abstain') || null}>
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
        alwaysExpanded: React.PropTypes.bool.isRequired,
        expanded: React.PropTypes.bool,
        onToggleExpand: React.PropTypes.func.isRequired,
        percent: React.PropTypes.object
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

    section (side) {
        return (
          <div style={this.voteWidth(side)} className={`progress-bar__section progress-bar__section--${side}`}>
            <span>{this.props.percent[side] + '%'}</span>
          </div>
        );
    },

    render () {
        return (
                <div
                  onClick={this.props.onToggleExpand}
                  className={`progress-bar progress-bar-stacked ${this.props.expanded && 'progress-bar--expanded'} ${this.props.alwaysExpanded && 'progress-bar--always-expanded'}`}>
                    {this.section('pro')}
                    {this.section('neutral')}
                    {this.section('con')}
                </div>);
    }
});
