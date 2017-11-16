/**
 * Opinions
 * @module Opinions
 */

import React from 'react'

import ArgumentForm from '../ArgumentForm';
import ArgumentsList from '../ArgumentsList';

import OpinionForm from './OpinionForm';
import OpinionSignUp from './OpinionSignUp';

const OpinionContainerProps = {
    actor: React.PropTypes.object.isRequired,
    argumentForm: React.PropTypes.bool.isRequired,
    argumentUrl: React.PropTypes.string,
    arguments: React.PropTypes.arrayOf(React.PropTypes.shape({
        id: React.PropTypes.number,
        displayName: React.PropTypes.string,
        side: React.PropTypes.string
    })),
    argumentsDisabled: React.PropTypes.bool.isRequired,
    buttonsType: React.PropTypes.string.isRequired,
    createArgument: React.PropTypes.object.isRequired,
    currentExplanation: React.PropTypes.object.isRequired,
    currentVote: React.PropTypes.string.isRequired,
    facebookUrl: React.PropTypes.string.isRequired,
    forgotPassword: React.PropTypes.object.isRequired,
    newArgumentButtons: React.PropTypes.bool.isRequired,
    newExplanation: React.PropTypes.string,
    newSelectedArguments: React.PropTypes.array.isRequired,
    onArgumentChange: React.PropTypes.func.isRequired,
    onArgumentSelectionChange: React.PropTypes.func.isRequired,
    onCloseOpinionForm: React.PropTypes.func.isRequired,
    onExplanationChange: React.PropTypes.func.isRequired,
    onOpenArgumentForm: React.PropTypes.func.isRequired,
    onOpenOpinionForm: React.PropTypes.func.isRequired,
    onSubmitArgument: React.PropTypes.func.isRequired,
    onShowAllArguments: React.PropTypes.func.isRequired,
    onSubmitOpinion: React.PropTypes.func.isRequired,
    opinionForm: React.PropTypes.bool.isRequired,
    selectedArguments: React.PropTypes.array.isRequired,
    showAllArguments: React.PropTypes.bool.isRequired,
    submitting: React.PropTypes.bool.isRequired
};
const OpinionContainer = props => {
    const { actor, argumentForm, currentVote, opinionForm, createArgument } = props;
    let component;
    if (argumentForm) {
        component = <ArgumentForm {...props}/>;
    } else if ((createArgument.shouldSubmit === true || currentVote !== 'abstain') && actor.actor_type === 'GuestUser') {
        component = <OpinionSignUp {...props}/>;
    } else if (props.currentVote === 'abstain' && props.buttonsType !== 'big') {
        component = <ArgumentsList arguments={props.arguments}
                                   argumentsDisabled={props.argumentsDisabled}
                                   showAllArguments={props.showAllArguments}
                                   onShowAllArguments={props.onShowAllArguments}
                                   onOpenArgumentForm={props.onOpenArgumentForm}/>
    } else if (opinionForm) {
        component = <OpinionForm {...props}/>;
    } else if (props.buttonsType !== 'big') {
        component = <ArgumentsList arguments={props.arguments}
                                   argumentsDisabled={props.argumentsDisabled}
                                   showAllArguments={props.showAllArguments}
                                   onShowAllArguments={props.onShowAllArguments}
                                   onOpenArgumentForm={props.onOpenArgumentForm}/>
    }
    return <div className={`opinion-form opinion-container-${props.currentVote}`}>{component}</div>;
};
OpinionContainer.propTypes = OpinionContainerProps;

export default OpinionContainer
