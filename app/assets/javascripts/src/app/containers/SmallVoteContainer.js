import React from 'react';
import { VoteButtons } from '../components/Vote';
import OpinionMixin from '../mixins/OpinionMixin';
import VoteMixin from '../mixins/VoteMixin';
import { IntlMixin } from 'react-intl';
import { OpinionContainer } from '../components/Opinions';

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
        argumentUrl: React.PropTypes.string,
        arguments: React.PropTypes.array,
        buttonsType: React.PropTypes.string,
        currentExplanation: React.PropTypes.object,
        currentVote: React.PropTypes.string,
        disabled: React.PropTypes.bool,
        disabledMessage: React.PropTypes.string,
        distribution: React.PropTypes.object,
        newArgumentButtons: React.PropTypes.bool,
        objectId: React.PropTypes.number,
        objectType: React.PropTypes.string,
        percent: React.PropTypes.object,
        r: React.PropTypes.string,
        selectedArguments: React.PropTypes.array,
        userRegistrationUrl: React.PropTypes.string,
        vote_url: React.PropTypes.string
    },

    mixins: [IntlMixin, OpinionMixin, VoteMixin],

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
            newExplanation: this.props.currentExplanation.explanation || '',
            newSelectedArguments: this.props.selectedArguments,
            opinionForm: false,
            percent: this.props.percent,
            selectedArguments: this.props.selectedArguments,
            signupEmail: '',
            submitting: false
        };
    },

    render () {
        let opinionContainer;
        if (this.state.currentVote !== 'abstain') {
            opinionContainer = <OpinionContainer actor={this.props.actor}
                                                 argumentUrl={this.props.argumentUrl}
                                                 argumentForm={this.state.argumentForm}
                                                 arguments={this.state.arguments}
                                                 createArgument={this.state.createArgument}
                                                 currentExplanation={this.state.currentExplanation}
                                                 currentVote={this.state.currentVote}
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
                                                 opinionForm={this.state.opinionForm}
                                                 selectedArguments={this.state.selectedArguments}
                                                 signupEmail={this.state.signupEmail}
                                                 submitting={this.state.submitting}
                                                 userRegistrationUrl={this.props.userRegistrationUrl}/>;
        }
        return (
            <div>
                <VoteButtons {...this.props} {...this.state} conHandler={this.conHandler} neutralHandler={this.neutralHandler} proHandler={this.proHandler} />
                {opinionContainer}
            </div>
        );
    }
});

window.SmallVoteContainer = SmallVoteContainer;
