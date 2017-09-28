import React from 'react'
import I18n from 'i18n-js';
import { CheckboxGroup } from '../CheckboxGroup';
import OnClickOutside from 'react-onclickoutside';

const OpinionForm = React.createClass({
    propTypes: {
        actor: React.PropTypes.object,
        arguments: React.PropTypes.arrayOf(React.PropTypes.shape({
            id: React.PropTypes.number,
            displayName: React.PropTypes.string,
            side: React.PropTypes.string
        })),
        currentExplanation: React.PropTypes.object.isRequired,
        currentVote: React.PropTypes.string.isRequired,
        newArgumentButtons: React.PropTypes.bool.isRequired,
        newExplanation: React.PropTypes.string,
        newSelectedArguments: React.PropTypes.array.isRequired,
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

    mixins: [
        OnClickOutside
    ],

    handleClickOutside () {
        this.props.onCloseOpinionForm();
    },

    render () {
        const { actor, newExplanation, newSelectedArguments, onArgumentSelectionChange, onExplanationChange, onSubmitOpinion, submitting } = this.props;
        const argumentFields = {};
        argumentFields['pro'] = [];
        argumentFields['con'] = [];
        this.props.arguments.forEach(argument => {
            argumentFields[argument.side].push({ label: argument.displayName, value: argument.id });
        });
        let argumentSelection, addArgumentProButton, addArgumentConButton, confirmHeader;
        if (this.props.newArgumentButtons) {
            addArgumentProButton = <span className="box-list-item">
                <a href="#">
                    <span data-value="pro" onClick={this.props.onOpenArgumentForm}>{I18n.t('arguments.new.pro')}</span>
                </a>
            </span>;
            addArgumentConButton = <span className="box-list-item">
                <a href="#">
                    <span data-value="con" onClick={this.props.onOpenArgumentForm}>{I18n.t('arguments.new.con')}</span>
                </a>
            </span>;
        }
        argumentSelection = <div>
            <label>{I18n.t('opinions.form.arguments')}</label>
            <div className="opinion-form__arguments-selector">
                <CheckboxGroup
                    childClass="pro-t"
                    onChange={onArgumentSelectionChange}
                    options={argumentFields['pro']}
                    value={newSelectedArguments}/>
                {addArgumentProButton}
            </div>
            <div className="opinion-form__arguments-selector">
                <CheckboxGroup
                    childClass="con-t"
                    onChange={onArgumentSelectionChange}
                    options={argumentFields['con']}
                    value={newSelectedArguments}/>
                {addArgumentConButton}
            </div>
        </div>;
        if (actor.confirmed === false) {
            confirmHeader = <p className="unconfirmed-vote-warning">{I18n.t('opinions.form.confirm_notice')} <strong>{actor.confirmationEmail}</strong>.</p>;
        }
        return (
            <form className={`formtastic formtastic--full-width ${submitting ? 'is-loading' : ''}`}
                  onSubmit={onSubmitOpinion}>
                <div className="box">
                    <section>
                        <div>
                            {confirmHeader}
                            <label>{I18n.t(`opinions.form.header.${actor.confirmed ? 'confirmed' : 'unconfirmed'}`)}</label>
                            <div>
                                <textarea
                                    name="opinion-body"
                                    autoFocus
                                    className="form-input-content"
                                    onChange={onExplanationChange}
                                    value={newExplanation}/>
                            </div>
                        </div>
                        {argumentSelection}
                    </section>
                    <section className="section--footer">
                        <fieldset className="actions">
                            <ol>
                                <div className="sticky-submit">
                                    <li className="action button_action">
                                        <button type="submit" disabled={submitting}>
                                            {I18n.t('opinions.form.submit')}
                                        </button>
                                    </li>
                                </div>
                            </ol>
                        </fieldset>
                    </section>
                </div>
            </form>
        )
    }
});

export default OpinionForm;
