/**
 * Opinions
 * @module Opinions
 */

import React from 'react'
import I18n from 'i18n-js';
import { CheckboxGroup } from './CheckboxGroup';
import OnClickOutside from 'react-onclickoutside';

export const OpinionContainer = React.createClass({
    propTypes: {
        actor: React.PropTypes.object.isRequired,
        arguments: React.PropTypes.arrayOf(React.PropTypes.shape({
            id: React.PropTypes.number,
            displayName: React.PropTypes.string,
            side: React.PropTypes.string
        })),
        currentExplanation: React.PropTypes.object.isRequired,
        currentVote: React.PropTypes.string.isRequired,
        newExplanation: React.PropTypes.string.isRequired,
        newSelectedArguments: React.PropTypes.array.isRequired,
        onArgumentChange: React.PropTypes.func.isRequired,
        onCloseOpinionForm: React.PropTypes.func.isRequired,
        onExplanationChange: React.PropTypes.func.isRequired,
        onOpenOpinionForm: React.PropTypes.func.isRequired,
        onSubmit: React.PropTypes.func.isRequired,
        opinionForm: React.PropTypes.bool.isRequired,
        selectedArguments: React.PropTypes.array.isRequired
    },

    render () {
        const { opinionForm } = this.props;
        let component;
        if (opinionForm) {
            component = <OpinionForm {...this.props}/>;
        } else if (this.props.currentExplanation.explanation === null || this.props.currentExplanation.explanation === '') {
            component = <OpinionAdd currentVote={this.props.currentVote} newExplanation={this.props.newExplanation} onOpenOpinionForm={this.props.onOpenOpinionForm}/>;
        } else {
            component = <OpinionShow {...this.props}/>;
        }
        return component;
    }
});
window.OpinionContainer = OpinionContainer;

const OpinionAdd = props => {
    const { currentVote, newExplanation, onOpenOpinionForm } = props;
    return (
        <form className={`formtastic formtastic--full-width opinion-form opinion-container-${currentVote}`}>
            <div className="box">
                <section>
                    <div>
                        <label>{I18n.t('opinions.form.header')}</label>
                        <div>
                                <textarea
                                    className="form-input-content"
                                    onClick={onOpenOpinionForm}
                                    value={newExplanation}/>
                        </div>
                    </div>
                </section>
            </div>
        </form>
    );
};
const opinionAddProps = {
    newExplanation: React.PropTypes.string.isRequired,
    currentVote: React.PropTypes.string.isRequired,
    onOpenOpinionForm: React.PropTypes.func.isRequired
};
OpinionAdd.propTypes = opinionAddProps;

export const OpinionForm = React.createClass({
    propTypes: {
        arguments: React.PropTypes.arrayOf(React.PropTypes.shape({
            id: React.PropTypes.number,
            displayName: React.PropTypes.string,
            side: React.PropTypes.string
        })),
        currentExplanation: React.PropTypes.object.isRequired,
        currentVote: React.PropTypes.string.isRequired,
        newExplanation: React.PropTypes.string.isRequired,
        newSelectedArguments: React.PropTypes.array.isRequired,
        onArgumentChange: React.PropTypes.func.isRequired,
        onCloseOpinionForm: React.PropTypes.func.isRequired,
        onExplanationChange: React.PropTypes.func.isRequired,
        onOpenOpinionForm: React.PropTypes.func.isRequired,
        onSubmit: React.PropTypes.func.isRequired,
        selectedArguments: React.PropTypes.array.isRequired
    },

    mixins: [
        OnClickOutside
    ],

    handleClickOutside () {
        this.props.onCloseOpinionForm();
    },

    render () {
        const { currentVote, newExplanation, newSelectedArguments, onArgumentChange, onExplanationChange, onSubmit } = this.props;
        const argumentFields = {};
        argumentFields['pro'] = [];
        argumentFields['con'] = [];
        this.props.arguments.forEach(argument => {
            argumentFields[argument.side].push({ label: argument.displayName, value: argument.id });
        });
        let argumentSelection;
        if (this.props.arguments.length > 0) {
            argumentSelection = <div>
                <label>{I18n.t('opinions.form.arguments')}</label>
                <CheckboxGroup
                    childClass="pro-t"
                    onChange={onArgumentChange}
                    options={argumentFields['pro']}
                    value={newSelectedArguments}
                    wrapperClass="opinion-form__arguments-selector"/>
                <CheckboxGroup
                    childClass="con-t"
                    onChange={onArgumentChange}
                    options={argumentFields['con']}
                    value={newSelectedArguments}
                    wrapperClass="opinion-form__arguments-selector"/>
            </div>
        }

        return (
            <form className={`formtastic formtastic--full-width opinion-form opinion-container-${currentVote}`}
                  onSubmit={onSubmit}>
                <div className="box">
                    <section>
                        <div>
                            <label>{I18n.t('opinions.form.header')}</label>
                            <div>
                                <textarea
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
                                    <li className="action button_action " id="motion_submit_action">
                                        <button type="submit">
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
window.OpinionForm = OpinionForm;

export const OpinionShow = React.createClass({
    propTypes: {
        actor: React.PropTypes.object.isRequired,
        arguments: React.PropTypes.arrayOf(React.PropTypes.shape({
            id: React.PropTypes.number,
            displayName: React.PropTypes.string,
            side: React.PropTypes.string
        })),
        currentExplanation: React.PropTypes.object.isRequired,
        currentVote: React.PropTypes.string.isRequired,
        onArgumentChange: React.PropTypes.func.isRequired,
        onCloseOpinionForm: React.PropTypes.func.isRequired,
        onExplanationChange: React.PropTypes.func.isRequired,
        onOpenOpinionForm: React.PropTypes.func.isRequired,
        onSubmit: React.PropTypes.func.isRequired,
        selectedArguments: React.PropTypes.array.isRequired
    },

    render () {
        const { currentExplanation: { explanation, explained_at }, onOpenOpinionForm, selectedArguments } = this.props;
        const argumentFields = {};
        argumentFields['pro'] = [];
        argumentFields['con'] = [];
        this.props.arguments
            .filter(argument => {
                return (selectedArguments.indexOf(argument.id) > -1);
            }).forEach(argument => {
                argumentFields[argument.side].push({ label: argument.displayName, value: argument.id });
            });
        return (
            <div className={`opinion-body opinion-container-${this.props.currentVote}`}>
                <div className="box">
                    <section>
                        <div className="markdown" itemProp="text">
                            <p>{explanation}</p>
                        </div>
                        <div className="opinion-body__arguments-list">
                            {argumentFields['pro'].map(result => { return <label className="pro-t" key={result.value}>{result.label}</label>; })}
                        </div>
                        <div className="opinion-body__arguments-list">
                            {argumentFields['con'].map(result => { return <label className="con-t" key={result.value}>{result.label}</label>; })}
                        </div>
                    </section>
                    <section className="section--footer">
                        <div className="profile-small">
                            <a href={this.props.actor.url}>
                                <img alt="profile-picture profile-picture--small" itemProp="image" src={this.props.actor.profile_photo}/>
                            </a>
                            <div className="info-block">
                                <a href={this.props.actor.url}>
                                    <span className="info">
                                        <time dateTime={explained_at}>{new Date(explained_at).toUTCString()}</time>
                                    </span>
                                    <div className="profile-name" itemProp="name">{this.props.actor.display_name}</div>
                                </a>
                            </div>
                        </div>
                        <ul className="btns-list--subtle btns-horizontal sticky--bottom-right btns-list--grey-background">
                            <li>
                                <div onClick={onOpenOpinionForm}>
                                    <div>
                                        <span className="fa fa-pencil"></span>
                                        <span className="icon-left">{I18n.t('opinions.form.edit')}</span>
                                    </div>
                                </div>
                            </li>
                        </ul>
                    </section>
                </div>
            </div>
        );
    }
});
window.OpinionShow = OpinionShow;
