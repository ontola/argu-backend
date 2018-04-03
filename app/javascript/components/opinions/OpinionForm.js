import React from 'react'
import I18n from 'i18n-js';
import { CheckboxGroup } from '../CheckboxGroup';

import Footer from '../forms/Footer';

const OpinionForm = React.createClass({
    propTypes: {
        actor: React.PropTypes.object,
        arguments: React.PropTypes.arrayOf(React.PropTypes.shape({
            id: React.PropTypes.number,
            displayName: React.PropTypes.string,
            side: React.PropTypes.string
        })),
        currentExplanation: React.PropTypes.object.isRequired,
        currentVote: React.PropTypes.object.isRequired,
        newArgumentButtons: React.PropTypes.bool.isRequired,
        newExplanation: React.PropTypes.string,
        onArgumentChange: React.PropTypes.func.isRequired,
        onArgumentSelectionChange: React.PropTypes.func.isRequired,
        onCloseOpinionForm: React.PropTypes.func.isRequired,
        onExplanationChange: React.PropTypes.func.isRequired,
        onOpenArgumentForm: React.PropTypes.func.isRequired,
        onOpenOpinionForm: React.PropTypes.func.isRequired,
        onSubmitOpinion: React.PropTypes.func.isRequired,
        selectedArguments: React.PropTypes.array.isRequired,
        submitting: React.PropTypes.bool.isRequired
    },

    addArgumentButton (side) {
        return (
            <li className="box-list-item--subtle">
                <a data-value={side} href="#" onClick={this.props.onOpenArgumentForm}>{I18n.t(`arguments.new.${side}`)}</a>
            </li>
        )
    },

    render () {
        const { actor, newExplanation, onArgumentSelectionChange, onExplanationChange, onSubmitOpinion, selectedArguments, submitting } = this.props;
        const argumentFields = {};
        argumentFields['pro'] = [];
        argumentFields['con'] = [];
        this.props.arguments.forEach(argument => {
            argumentFields[argument.side].push({ label: argument.displayName, value: argument.id });
        });
        let argumentSelection, addArgumentProButton, addArgumentConButton, confirmHeader;
        if (this.props.newArgumentButtons) {
            addArgumentProButton = this.addArgumentButton('pro');
            addArgumentConButton = this.addArgumentButton('con');
        }
        argumentSelection = <div>
            <label>{I18n.t('opinions.form.arguments')}</label>
            <div className="opinion-form__arguments-selector">
                <CheckboxGroup
                    childClass="pro-t"
                    inputOpts={{ 'data-side': 'pro' }}
                    onChange={onArgumentSelectionChange}
                    options={argumentFields['pro']}
                    value={selectedArguments}/>
                {addArgumentProButton}
            </div>
            <div className="opinion-form__arguments-selector">
                <CheckboxGroup
                    childClass="con-t"
                    inputOpts={{ 'data-side': 'con' }}
                    onChange={onArgumentSelectionChange}
                    options={argumentFields['con']}
                    value={selectedArguments}/>
                {addArgumentConButton}
            </div>
        </div>;
        if (actor.confirmed === false) {
            confirmHeader = <p className="unconfirmed-vote-warning">{I18n.t('opinions.form.confirm_notice')} <strong>{actor.confirmationEmail}</strong>.</p>;
        }
        return (
            <form className={`formtastic formtastic--full-width ${submitting ? 'is-loading' : ''}`}
                  onSubmit={onSubmitOpinion}>
                <section className="section--bottom">
                    <div>
                        {confirmHeader}
                        {argumentSelection}
                        <div>
                            <textarea
                                name="opinion-body"
                                autoFocus
                                className="form-input-content"
                                onChange={onExplanationChange}
                                placeholder={I18n.t('opinions.form.placeholder')}
                                value={newExplanation}/>
                        </div>
                    </div>
                </section>
                <Footer cancelButton={I18n.t('opinions.form.cancel')}
                        disabled={submitting}
                        onCancel={this.props.onCloseOpinionForm}
                        submitButton={I18n.t('opinions.form.submit')}/>
            </form>
        )
    }
});

export default OpinionForm;
