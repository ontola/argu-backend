/*globals Bugsnag*/
import Alert from '../components/Alert';
import React from 'react';
import { safeCredentials, statusSuccess, json } from '../lib/helpers';
import actorStore from '../stores/actor_store';
import { VoteButtons, VoteResults } from '../components/Vote';
import VoteMixin from '../mixins/VoteMixin';
import { IntlMixin } from 'react-intl';

/**
 * Component that displays current vote options based on whether the user is member of a group.
 * Also reveals the results if the user has already voted.
 * This component is not pure.
 * @class
 * @exports BigVoteContainer
 * @see {@linkcode Vote.VoteButtons}
 * @see {@linkcode Vote.VoteResults}
 */
export const BigVoteContainer = React.createClass({
    propTypes: {
        actor: React.PropTypes.object,
        closed: React.PropTypes.bool,
        currentVote: React.PropTypes.string,
        distribution: React.PropTypes.object,
        groups: React.PropTypes.array,
        objectId: React.PropTypes.number,
        objectType: React.PropTypes.string,
        percent: React.PropTypes.object,
        vote_url: React.PropTypes.string
    },

    mixins: [IntlMixin, VoteMixin],

    getInitialState () {
        return {
            actor: this.props.actor || null,
            groups: this.props.groups,
            objectType: this.props.objectType,
            objectId: this.props.objectId,
            currentVote: this.props.currentVote,
            distribution: this.props.distribution,
            percent: this.props.percent
        };
    },

    componentDidMount () {
        this.unsubscribe = actorStore.listen(this.onActorChange);
    },

    componentWillUnmount () {
        this.unsubscribe();
    },

    refreshGroups () {
        fetch(`${this.state.objectId}.json`, safeCredentials())
                .then(statusSuccess)
                .then(json)
                .then(data => {
                    this.setState({ groups: data.groups });
                }).catch(e => {
                    Alert('Er is iets fout gegaan, probeer het opnieuw._', 'alert', true);
                    Bugsnag.notifyException(e);
                });
    },

    setVote (vote) {
        this.setState(vote);
    },

    render () {
        let voteButtonsComponent, voteResultsComponent;
        if (!this.state.actor || this.state.actor.actor_type === 'User' || this.state.actor.actor_type === 'GuestUser') {
            voteButtonsComponent = <VoteButtons {...this.props} {...this.state} conHandler={this.conHandler} neutralHandler={this.neutralHandler} proHandler={this.proHandler}/>;
            voteResultsComponent = <VoteResults {...this.state} showResults={this.props.closed || this.state.currentVote !== 'abstain'}/>;
        } else if (this.state.actor.actor_type === 'Page') {
            voteResultsComponent = <VoteResults {...this.state} {...this.props} showResults={true}/>;
        }

        return (
                <div className="center motion-shr">
                    {voteButtonsComponent}
                    {voteResultsComponent}
                </div>
        );
    }
});
window.BigVoteContainer = BigVoteContainer;
