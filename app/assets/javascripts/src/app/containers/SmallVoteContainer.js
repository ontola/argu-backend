import React from 'react';
import { VoteButtons } from '../components/Vote';
import VoteMixin from '../mixins/VoteMixin';
import { IntlMixin } from 'react-intl';

/**
 * Component that displays current vote options.
 * This component is not pure.
 * @class
 * @exports SmallVoteContainer
 * @see {@linkcode Vote.VoteButtons}
 */
export const SmallVoteContainer = React.createClass({
    propTypes: {
        actor: React.PropTypes.object,
        buttonsType: React.PropTypes.string,
        closed: React.PropTypes.bool,
        currentVote: React.PropTypes.string,
        distribution: React.PropTypes.object,
        objectId: React.PropTypes.number,
        objectType: React.PropTypes.string,
        percent: React.PropTypes.object,
        r: React.PropTypes.string,
        vote_url: React.PropTypes.string
    },

    mixins: [IntlMixin, VoteMixin],

    getInitialState () {
        return {
            actor: this.props.actor || null,
            objectType: this.props.objectType,
            objectId: this.props.objectId,
            currentVote: this.props.currentVote,
            distribution: this.props.distribution,
            percent: this.props.percent
        };
    },

    render () {
        return (<VoteButtons {...this.props} {...this.state} conHandler={this.conHandler} neutralHandler={this.neutralHandler} proHandler={this.proHandler} />);
    }
});

window.SmallVoteContainer = SmallVoteContainer;
