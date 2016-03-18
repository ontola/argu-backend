import Alert from './Alert';
import React from 'react';
import { safeCredentials, statusSuccess, json } from '../lib/helpers';
import actorStore from '../stores/actor_store';
import { BigVoteButtons, BigVoteResults } from './BigVote';
import BigGroupResponse from './_big_group_responses';

/**
 * Component that displays current vote options based on whether the user is member of a group.
 * Also reveals the results if the user has already voted.
 * This component is not pure.
 * @class
 * @exports CombiBigVote
 * @see {@linkcode BigVote.BigVoteButtons}
 * @see {@linkcode BigVote.BigVoteResults}
 * @see {@linkcode BigGroupResponse}
 */
export const CombiBigVote = React.createClass({

    getInitialState: function () {
        return {
            actor: this.props.actor,
            groups: this.props.groups,
            object_type: this.props.object_type,
            object_id: this.props.object_id,
            current_vote: this.props.current_vote,
            distribution: this.props.distribution,
            percent: this.props.percent
        };
    },

    onActorChange: function (actor) {
        this.refreshGroups();
        this.setState({actor: actor});
    },

    componentDidMount: function () {
        this.unsubscribe = actorStore.listen(this.onActorChange);
    },

    componentWillUnmount: function () {
        this.unsubscribe();
    },

    setVote: function (vote) {
        this.setState(vote);
    },

    refreshGroups: function () {
        fetch(`${this.state.object_id}.json`, safeCredentials())
                .then(statusSuccess)
                .then(json)
                .then((data) => {
                    this.setState({groups: data.groups});
                }).catch((e) => {
                    Alert('Er is iets fout gegaan, probeer het opnieuw._', 'alert', true);
                    Bugsnag.notifyException(e);
                });
    },

    render: function () {
        let voteButtonsComponent;
        let voteResultsComponent;
        let groupResponsesComponent;
        if (!this.state.actor || this.state.actor.actor_type === 'User') {
            voteButtonsComponent = <BigVoteButtons parentSetVote={this.setVote} {...this.state} {...this.props}/>;
            voteResultsComponent = <BigVoteResults {...this.state} show_results={this.state.current_vote !== 'abstain'}/>;
            groupResponsesComponent = <BigGroupResponse groups={this.state.groups || []} actor={this.state.actor} object_type={this.props.object_type} object_id={this.props.object_id} />;
        } else if (this.state.actor.actor_type === 'Page') {
            groupResponsesComponent = <BigGroupResponse groups={this.state.groups || []} actor={this.state.actor} object_type={this.props.object_type} object_id={this.props.object_id} />;
            voteResultsComponent = <BigVoteResults {...this.state} {...this.props} show_results={true}/>;
        }

        return (
                <div className="center motion-shr">
                    {voteButtonsComponent}
                    {groupResponsesComponent}
                </div>
        );
    }
});
window.CombiBigVote = CombiBigVote;
