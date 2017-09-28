/**
 * Opinions
 * @module Opinions
 */

import React from 'react'

import ArgumentForm from '../ArgumentForm';

import OpinionAdd from './OpinionAdd';
import OpinionForm from './OpinionForm';
import OpinionShow from './OpinionShow';
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
    createArgument: React.PropTypes.object.isRequired,
    currentExplanation: React.PropTypes.object.isRequired,
    currentVote: React.PropTypes.string.isRequired,
    facebookUrl: React.PropTypes.string.isRequired,
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
    onSubmitOpinion: React.PropTypes.func.isRequired,
    onSubmitRegistration: React.PropTypes.func.isRequired,
    opinionForm: React.PropTypes.bool.isRequired,
    selectedArguments: React.PropTypes.array.isRequired,
    submitting: React.PropTypes.bool.isRequired
};
const OpinionContainer = props => {
    const { actor, argumentForm, currentVote, opinionForm } = props;
    let component;
    if (argumentForm) {
        component = <ArgumentForm {...props}/>;
    } else if (currentVote !== 'abstain' && actor.actor_type === 'GuestUser') {
        component = <OpinionSignUp {...props}/>;
    } else if (opinionForm) {
        component = <OpinionForm {...props}/>;
    } else if (props.currentExplanation.explanation === null || props.currentExplanation.explanation === '') {
        component = <OpinionAdd actor={props.actor} currentVote={props.currentVote} newExplanation={props.newExplanation} onOpenOpinionForm={props.onOpenOpinionForm}/>;
    } else {
        component = <OpinionShow {...props}/>;
    }
    return <div className={`opinion-form opinion-container-${props.currentVote}`}>{component}</div>;
};
OpinionContainer.propTypes = OpinionContainerProps;

export default OpinionContainer
