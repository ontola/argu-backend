/*global $*/
import React from 'react/addons';
import Intl from  'intl';
import 'intl/locale-data/jsonp/en.js';
import { IntlMixin, FormattedMessage } from 'react-intl';
import { safeCredentials, statusSuccess, json } from '../lib/helpers';
import actorStore from '../stores/actor_store';

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
                }).catch(() => {
                    Argu.Alert('_Er is iets fout gegaan, probeer het opnieuw._', 'alert', true);
                });
    },

    render: function () {
        let voteButtonsComponent;
        let voteResultsComponent;
        let groupResponsesComponent;
        if (!this.state.actor || this.state.actor.actor_type == "User") {
            voteButtonsComponent = <BigVoteButtons parentSetVote={this.setVote} {...this.state} {...this.props}/>;
            voteResultsComponent = <BigVoteResults {...this.state} show_results={this.state.current_vote !== "abstain"}/>;
            groupResponsesComponent = <BigGroupResponse groups={this.state.groups || []} actor={this.state.actor} object_type={this.props.object_type} object_id={this.props.object_id} />;
        } else if (this.state.actor.actor_type == "Page") {
            groupResponsesComponent = <BigGroupResponse groups={this.state.groups || []} actor={this.state.actor} object_type={this.props.object_type} object_id={this.props.object_id} />;
            voteResultsComponent = <BigVoteResults {...this.state} {...this.props} show_results={true}/>;
        }

        return (
                <div className="center motion-shr">
                    {voteButtonsComponent}
                    {voteResultsComponent}
                    {groupResponsesComponent}
                </div>
        );
    }
});
window.CombiBigVote = CombiBigVote;
