import React from 'react';

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
        argumentsDisabled: React.PropTypes.bool,
        buttonsType: React.PropTypes.string,
        currentVote: React.PropTypes.object,
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
        totalVotes: React.PropTypes.number,
        upvoteOnly: React.PropTypes.bool,
        userRegistrationUrl: React.PropTypes.string,
        vote_path: React.PropTypes.string
    },

    mixins: [OpinionMixin, VoteMixin],

    getInitialState () {
        let highlightedId;
        if (typeof window !== 'undefined') {
            highlightedId = parseInt(window.location.hash.split('motion')[1], 10);
        }
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
            currentVote: this.props.currentVote,
            distribution: this.props.distribution,
            loginStep: 'initial',
            opinionForm: (highlightedId === this.props.objectId),
            percent: this.props.percent,
            selectedArguments: this.props.selectedArguments,
            showAllArguments: false,
            showExpandedVoteResults: false,
            signupEmail: '',
            signupPassword: '',
            submitting: false,
            submittingVote: ''
        };
    },

    render () {
        let voteResultsComponent, bottomBody;
        const voteButtonsComponent = <VoteButtons
                                        {...this.props}
                                        {...this.state}
                                        conHandler={this.conHandler}
                                        neutralHandler={this.neutralHandler}
                                        proHandler={this.proHandler}/>;
        if (this.props.totalVotes > 0 && !this.props.upvoteOnly) {
            voteResultsComponent = <VoteResults
            {...this.state}
            alwaysExpanded={(this.props.buttonsType === 'big')}
            onToggleExpand={this.expandVoteResultsHandler}
            expanded={this.props.buttonsType === 'big' || this.state.showExpandedVoteResults}
            total_votes={this.props.totalVotes}/>;
        }
        bottomBody = <OpinionContainer actor={this.props.actor}
                                       argumentUrl={this.props.argumentUrl}
                                       argumentForm={this.state.argumentForm}
                                       arguments={this.state.arguments}
                                       argumentsDisabled={this.props.argumentsDisabled}
                                       buttonsType={this.props.buttonsType}
                                       createArgument={this.state.createArgument}
                                       currentVote={this.state.currentVote}
                                       errorMessage={this.state.errorMessage}
                                       facebookUrl={this.props.facebookUrl}
                                       forgotPassword={this.props.forgotPassword}
                                       loginStep={this.state.loginStep}
                                       newArgumentButtons={this.props.newArgumentButtons}
                                       onArgumentChange={this.argumentChangeHandler}
                                       onArgumentSelectionChange={this.argumentSelectionChangeHandler}
                                       onCancelLogin={this.handleCancelLogin}
                                       onCloseArgumentForm={this.closeArgumentFormHandler}
                                       onCloseOpinionForm={this.closeOpinionFormHandler}
                                       onOpenArgumentForm={this.openArgumentFormHandler}
                                       onOpenOpinionForm={this.openOpinionFormHandler}
                                       onSignupEmailChange={this.signupEmailChangeHandler}
                                       onSignupPasswordChange={this.handleSignupEmailChange}
                                       onShowAllArguments={this.handleShowAllArguments}
                                       onSubmitArgument={this.argumentHandler}
                                       onSubmitEmail={this.state.loginStep === 'register' ? this.handleRegistration : this.handleLogin}
                                       onSubmitOpinion={this.opinionHandler}
                                       opinionForm={this.state.opinionForm}
                                       policyPath={this.props.policyPath}
                                       selectedArguments={this.state.selectedArguments}
                                       signupEmail={this.state.signupEmail}
                                       signupPassword={this.state.signupPassword}
                                       showAllArguments={this.state.showAllArguments}
                                       submitting={this.state.submitting}/>;

        return (
                <div className="motion-shr">
                    {voteButtonsComponent}
                    {voteResultsComponent}
                    {bottomBody}
                </div>
        );
    }
});

export default VoteContainer;
