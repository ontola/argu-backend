/*globals Bugsnag*/
import Alert from './Alert';
import React from 'react';
import { safeCredentials, statusSuccess, json } from '../lib/helpers';
import actorStore from '../stores/actor_store';
import { VoteButtons, VoteResults } from './Vote';
import BigGroupResponse from './_big_group_responses';
import VoteMixin from '../mixins/VoteMixin';
import { IntlMixin } from 'react-intl';

/**
 * Component that displays current vote options based on whether the user is member of a group.
 * Also reveals the results if the user has already voted.
 * This component is not pure.
 * @class
 * @exports CombiVote
 * @see {@linkcode Vote.VoteButtons}
 * @see {@linkcode Vote.VoteResults}
 * @see {@linkcode BigGroupResponse}
 */
export const CombiVote = React.createClass({
    mixins: [IntlMixin, VoteMixin],

    propTypes: {
        actor: React.PropTypes.object,
        currentVote: React.PropTypes.string,
        distribution: React.PropTypes.object,
        groups: React.PropTypes.array,
        objectType: React.PropTypes.string,
        objectId: React.PropTypes.number,
        percent: React.PropTypes.object
    },

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
        let voteButtonsComponent, groupResponsesComponent;
        if (!this.state.actor || this.state.actor.actor_type === 'User') {
            voteButtonsComponent = <VoteButtons {...this.state} {...this.props}/>;
            voteResultsComponent = <VoteResults {...this.state} showResults={this.state.currentVote !== 'abstain'}/>;
            groupResponsesComponent = <BigGroupResponse groups={this.state.groups || []} actor={this.state.actor} objectType={this.props.objectType} objectId={this.props.objectId} />;
        } else if (this.state.actor.actor_type === 'Page') {
            groupResponsesComponent = <BigGroupResponse groups={this.state.groups || []} actor={this.state.actor} objectType={this.props.objectType} objectId={this.props.objectId} />;
            voteResultsComponent = <VoteResults {...this.state} {...this.props} showResults={true}/>;
        }

        return (
                <div className="center motion-shr">
                    {voteButtonsComponent}
                    {groupResponsesComponent}
                </div>
        );
    }
});
window.CombiVote = CombiVote;
