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
        currentVote: React.PropTypes.object.isRequired,
        newArgumentButtons: React.PropTypes.bool.isRequired,
        onArgumentChange: React.PropTypes.func.isRequired,
        onArgumentSelectionChange: React.PropTypes.func.isRequired,
        onCloseOpinionForm: React.PropTypes.func.isRequired,
        onOpenArgumentForm: React.PropTypes.func.isRequired,
        onOpenOpinionForm: React.PropTypes.func.isRequired,
        onSubmitOpinion: React.PropTypes.func.isRequired,
        selectedArguments: React.PropTypes.array.isRequired,
        submitting: React.PropTypes.bool.isRequired
    },

    getInitialState () {
        return {
            comment: this.props.currentVote.comment && this.props.currentVote.comment.body || ''
        }
    },

    componentWillReceiveProps(nextProps) {
        if (nextProps.currentVote !== this.props.currentVote) {
            this.setState({ comment: nextProps.currentVote.comment && nextProps.currentVote.comment.body || '' });
        }
    },

    addArgumentButton (side) {
        return (
            <li className="box-list-item--subtle">
                <a data-value={side} href="#" onClick={this.props.onOpenArgumentForm}>{I18n.t(`arguments.new.${side}`)}</a>
            </li>
        )
    },

    changeHandler (e) {
        this.setState({ comment: e.target.value });
    },

    invalid () {
        return this.props.currentVote.comment.body !== '' && this.state.comment === '' || this.state.comment.length < 4;
    },

    onSubmitOpinion (e) {
        e.preventDefault();
        if (this.state.comment === '') {
            this.props.onCloseOpinionForm(e);
        } else {
            this.props.onSubmitOpinion(this.state.comment);
        }
    },

    render () {
        const { actor, onArgumentSelectionChange, selectedArguments, submitting } = this.props;
        const argumentFields = {};
        argumentFields['pro'] = [];
        argumentFields['con'] = [];
        this.props.arguments.forEach(argument => {
            argumentFields[argument.side].push({ label: argument.displayName, value: argument.id, iri: argument.url });
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
                    onChange={onArgumentSelectionChange}
                    options={argumentFields['pro']}
                    value={selectedArguments}/>
                {addArgumentProButton}
            </div>
            <div className="opinion-form__arguments-selector">
                <CheckboxGroup
                    childClass="con-t"
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
                  onSubmit={this.onSubmitOpinion}>
                <section className="section--bottom">
                    <div>
                        {confirmHeader}
                        {argumentSelection}
                        <div>
                            <textarea
                                name="opinion-body"
                                autoFocus
                                className="form-input-content"
                                onChange={this.changeHandler}
                                placeholder={I18n.t('opinions.form.placeholder')}
                                value={this.state.comment}/>
                        </div>
                    </div>
                </section>
                <Footer cancelButton={I18n.t('opinions.form.cancel')}
                        disabled={submitting || this.invalid()}
                        onCancel={this.props.onCloseOpinionForm}
                        submitButton={I18n.t('opinions.form.submit')}/>
            </form>
        )
    }
});

export default OpinionForm;
