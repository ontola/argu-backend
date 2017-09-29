import React from 'react';

import actorStore from './stores/actor_store';
import { VoteButtons, VoteResults } from './Vote';
import OpinionMixin from './mixins/OpinionMixin';
import VoteMixin from './mixins/VoteMixin';
import OpinionContainer from './opinions/OpinionContainer';

/**
 * Component that displays current vote options based on whether the user is member of a group.
 * Also reveals the results if the user has already voted.
 * This component is not pure.
 * @class
 * @exports VoteContainer
 * @see {@linkcode Vote.VoteButtons}
 * @see {@linkcode Vote.VoteResults}
 */
export const VoteContainer = React.createClass({
    propTypes: {
        actor: React.PropTypes.object,
        argumentUrl: React.PropTypes.string,
        arguments: React.PropTypes.array,
        buttonsType: React.PropTypes.string,
        currentExplanation: React.PropTypes.object,
        currentVote: React.PropTypes.string,
        disabled: React.PropTypes.bool,
        disabledMessage: React.PropTypes.string,
        distribution: React.PropTypes.object,
        facebookUrl: React.PropTypes.string,
        forgotPassword: React.PropTypes.object,
        newArgumentButtons: React.PropTypes.bool,
        oauthTokenUrl: React.PropTypes.string,
        objectId: React.PropTypes.number,
        objectType: React.PropTypes.string,
        percent: React.PropTypes.object,
        policyPath: React.PropTypes.string,
        r: React.PropTypes.string,
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
            loginStep: 'initial',
            newExplanation: this.props.currentExplanation.explanation || '',
            newSelectedArguments: this.props.selectedArguments,
            opinionForm: false,
            percent: this.props.percent,
            selectedArguments: this.props.selectedArguments,
            signupEmail: '',
            signupPassword: '',
            submitting: false,
            submittingVote: ''
        };
    },

    componentDidMount () {
        this.unsubscribe = actorStore.listen(this.onActorChange);
    },

    componentWillUnmount () {
        this.unsubscribe();
    },

    render () {
        let voteResultsComponent, opinionContainer;
        const voteButtonsComponent = <VoteButtons {...this.props} {...this.state} conHandler={this.conHandler} neutralHandler={this.neutralHandler} proHandler={this.proHandler}/>;
        if (this.props.buttonsType === 'big') {
            voteResultsComponent = <VoteResults {...this.state} showResults={this.props.disabled || this.state.currentVote !== 'abstain'}/>;
        }
        if (this.state.currentVote !== 'abstain') {
            opinionContainer = <OpinionContainer actor={this.state.actor}
                                                 argumentUrl={this.props.argumentUrl}
                                                 argumentForm={this.state.argumentForm}
                                                 arguments={this.state.arguments}
                                                 createArgument={this.state.createArgument}
                                                 currentExplanation={this.state.currentExplanation}
                                                 currentVote={this.state.currentVote}
                                                 errorMessage={this.state.errorMessage}
                                                 facebookUrl={this.props.facebookUrl}
                                                 forgotPassword={this.props.forgotPassword}
                                                 loginStep={this.state.loginStep}
                                                 newArgumentButtons={this.props.newArgumentButtons}
                                                 newExplanation={this.state.newExplanation}
                                                 newSelectedArguments={this.state.newSelectedArguments}
                                                 onArgumentChange={this.argumentChangeHandler}
                                                 onArgumentSelectionChange={this.argumentSelectionChangeHandler}
                                                 onCancelLogin={this.handleCancelLogin}
                                                 onCloseArgumentForm={this.closeArgumentFormHandler}
                                                 onCloseOpinionForm={this.closeOpinionFormHandler}
                                                 onExplanationChange={this.explanationChangeHandler}
                                                 onOpenArgumentForm={this.openArgumentFormHandler}
                                                 onOpenOpinionForm={this.openOpinionFormHandler}
                                                 onSignupEmailChange={this.signupEmailChangeHandler}
                                                 onSignupPasswordChange={this.handleSignupEmailChange}
                                                 onSubmitArgument={this.argumentHandler}
                                                 onSubmitEmail={this.state.loginStep === 'register' ? this.handleRegistration : this.handleLogin}
                                                 onSubmitOpinion={this.opinionHandler}
                                                 opinionForm={this.state.opinionForm}
                                                 policyPath={this.props.policyPath}
                                                 selectedArguments={this.state.selectedArguments}
                                                 signupEmail={this.state.signupEmail}
                                                 signupPassword={this.state.signupPassword}
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

export default VoteContainer;
