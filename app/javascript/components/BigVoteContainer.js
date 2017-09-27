import React from 'react';

import actorStore from './stores/actor_store';
import { VoteButtons, VoteResults } from './Vote';
import OpinionMixin from './mixins/OpinionMixin';
import VoteMixin from './mixins/VoteMixin';
import { OpinionContainer } from './Opinions';

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
        argumentUrl: React.PropTypes.string,
        arguments: React.PropTypes.array,
        currentExplanation: React.PropTypes.object,
        currentVote: React.PropTypes.string,
        disabled: React.PropTypes.bool,
        disabledMessage: React.PropTypes.string,
        distribution: React.PropTypes.object,
        facebookUrl: React.PropTypes.string,
        newArgumentButtons: React.PropTypes.bool,
        objectId: React.PropTypes.number,
        objectType: React.PropTypes.string,
        percent: React.PropTypes.object,
        selectedArguments: React.PropTypes.array,
        userRegistrationUrl: React.PropTypes.string,
        vote_url: React.PropTypes.string
    },

    mixins: [OpinionMixin, VoteMixin],

    getInitialState () {
        return {
            actor: this.props.actor || null,
            argumentForm: false,
            arguments: this.props.arguments,
            createArgument: {
                side: undefined,
                title: '',
                body: ''
            },
            objectType: this.props.objectType,
            objectId: this.props.objectId,
            currentExplanation: this.props.currentExplanation,
            currentVote: this.props.currentVote,
            distribution: this.props.distribution,
            newExplanation: this.props.currentExplanation.explanation,
            newSelectedArguments: this.props.selectedArguments,
            opinionForm: false,
            percent: this.props.percent,
            selectedArguments: this.props.selectedArguments,
            signupEmail: '',
            submitting: false
        };
    },

    componentDidMount () {
        this.unsubscribe = actorStore.listen(this.onActorChange);
    },

    componentWillUnmount () {
        this.unsubscribe();
    },

    render () {
        let voteButtonsComponent, voteResultsComponent, opinionContainer;
        if (!this.state.actor || this.state.actor.actor_type === 'User' || this.state.actor.actor_type === 'GuestUser') {
            voteButtonsComponent = <VoteButtons {...this.props} {...this.state} conHandler={this.conHandler} neutralHandler={this.neutralHandler} proHandler={this.proHandler}/>;
            voteResultsComponent = <VoteResults {...this.state} showResults={this.props.disabled || this.state.currentVote !== 'abstain'}/>;
        } else if (this.state.actor.actor_type === 'Page') {
            voteResultsComponent = <VoteResults {...this.state} {...this.props} showResults={true}/>;
        }
        if (this.state.currentVote !== 'abstain') {
            opinionContainer = <OpinionContainer actor={this.state.actor}
                                                 argumentUrl={this.props.argumentUrl}
                                                 argumentForm={this.state.argumentForm}
                                                 arguments={this.state.arguments}
                                                 createArgument={this.state.createArgument}
                                                 currentExplanation={this.state.currentExplanation}
                                                 currentVote={this.state.currentVote}
                                                 facebookUrl={this.props.facebookUrl}
                                                 newArgumentButtons={this.props.newArgumentButtons}
                                                 newExplanation={this.state.newExplanation}
                                                 newSelectedArguments={this.state.newSelectedArguments}
                                                 onArgumentChange={this.argumentChangeHandler}
                                                 onArgumentSelectionChange={this.argumentSelectionChangeHandler}
                                                 onCloseArgumentForm={this.closeArgumentFormHandler}
                                                 onCloseOpinionForm={this.closeOpinionFormHandler}
                                                 onExplanationChange={this.explanationChangeHandler}
                                                 onOpenArgumentForm={this.openArgumentFormHandler}
                                                 onOpenOpinionForm={this.openOpinionFormHandler}
                                                 onSignupEmailChange={this.signupEmailChangeHandler}
                                                 onSubmitArgument={this.argumentHandler}
                                                 onSubmitOpinion={this.opinionHandler}
                                                 onSubmitRegistration={this.registrationHandler}
                                                 opinionForm={this.state.opinionForm}
                                                 selectedArguments={this.state.selectedArguments}
                                                 signupEmail={this.state.signupEmail}
                                                 submitting={this.state.submitting}/>;
        }
        return (
                <div className="center motion-shr">
                    {voteButtonsComponent}
                    {opinionContainer}
                    {voteResultsComponent}
                </div>
        );
    }
});

export default BigVoteContainer;
