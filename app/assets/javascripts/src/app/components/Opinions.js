/**
 * Opinions
 * @module Opinions
 */

import React from 'react'
import I18n from 'i18n-js';
import { ArgumentForm } from './ArgumentForm';
import { CheckboxGroup } from './CheckboxGroup';
import OnClickOutside from 'react-onclickoutside';
import { getAuthenticityToken } from '../lib/helpers';

export const OpinionContainer = props => {
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
    opinionForm: React.PropTypes.bool.isRequired,
    selectedArguments: React.PropTypes.array.isRequired,
    submitting: React.PropTypes.bool.isRequired
};
OpinionContainer.propTypes = OpinionContainerProps;

const OpinionAdd = props => {
    const { actor, newExplanation, onOpenOpinionForm } = props;
    let confirmHeader;
    if (actor.confirmed === false) {
        confirmHeader = <p className="block-slogan">{I18n.t('opinions.form.confirm')}</p>;
    }
    return (
        <form className={"formtastic formtastic--full-width"}>
            <div className="box">
                <section>
                    <div>
                        {confirmHeader}
                        <label>{I18n.t(`opinions.form.header.${actor.confirmed ? 'confirmed' : 'unconfirmed'}`)}</label>
                        <div>
                            <textarea
                                name="opinion-body"
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
    actor: React.PropTypes.object,
    newExplanation: React.PropTypes.string,
    currentVote: React.PropTypes.string.isRequired,
    onOpenOpinionForm: React.PropTypes.func.isRequired
};
OpinionAdd.propTypes = opinionAddProps;

export const OpinionSignUp = React.createClass({
    propTypes: {
        facebookUrl: React.PropTypes.string.isRequired,
        onSignupEmailChange: React.PropTypes.func.isRequired,
        signupEmail: React.PropTypes.string.isRequired,
        userRegistrationUrl: React.PropTypes.string.isRequired
    },

    getInitialState () {
        return {
            authenticityToken: '',
            currentUrl: ''
        }
    },

    componentDidMount () {
        this.setState({ authenticityToken: getAuthenticityToken(), currentUrl: window.location.href });
    },

    render () {
        const { facebookUrl, onSignupEmailChange, signupEmail, userRegistrationUrl } = this.props;
        return (
            <form action={userRegistrationUrl} className={"formtastic formtastic--full-width"} method="post">
                <input type="hidden" name="authenticity_token" value={this.state.authenticityToken}/>
                <input type="hidden" name="user[r]" value={this.state.currentUrl}/>
                <div className="box">
                    <section>
                        <div>
                            <label>{I18n.t('opinions.form.signup')}</label>
                            <div>
                                <input
                                    name="user[email]"
                                    className="form-input-content"
                                    onChange={onSignupEmailChange}
                                    placeholder={I18n.t('opinions.form.email.placeholder')}
                                    type="email"
                                    value={signupEmail}/>
                            </div>
                            <div>
                                <a className="btn btn--facebook" data-turbolinks="false" href={facebookUrl}>
                                    <span className="fa fa-facebook" />
                                    <span className="icon-left">{I18n.t('opinions.form.facebook_login')}</span>
                                </a>
                            </div>
                            <div className="info">{I18n.t('opinions.form.facebook_notice')}</div>
                        </div>
                    </section>
                    <section className="section--footer">
                        <fieldset className="actions">
                            <ol>
                                <div className="sticky-submit">
                                    <li className="action button_action">
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
window.OpinionSignUp = OpinionSignUp;

export const OpinionForm = React.createClass({
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
            confirmHeader = <p className="block-slogan">{I18n.t('opinions.form.confirm')}</p>;
        }
        return (
            <form className="formtastic formtastic--full-width"
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
        onArgumentSelectionChange: React.PropTypes.func.isRequired,
        onCloseOpinionForm: React.PropTypes.func.isRequired,
        onExplanationChange: React.PropTypes.func.isRequired,
        onOpenOpinionForm: React.PropTypes.func.isRequired,
        selectedArguments: React.PropTypes.array.isRequired
    },

    iconForSide () {
        switch (this.props.currentVote) {
        case 'pro':
            return 'thumbs-up';
        case 'neutral':
            return 'pause';
        case 'con':
            return 'thumbs-down';
        }
    },

    render () {
        const { actor, currentExplanation: { explanation, explained_at }, onOpenOpinionForm, selectedArguments } = this.props;
        const argumentFields = {};
        argumentFields['pro'] = [];
        argumentFields['con'] = [];
        this.props.arguments
            .filter(argument => {
                return (selectedArguments.indexOf(argument.id) > -1);
            }).forEach(argument => {
                argumentFields[argument.side].push({ label: argument.displayName, url: argument.url, value: argument.id });
            });
        let confirmHeader;
        if (actor.confirmed === false) {
            confirmHeader = <p className="block-slogan">{I18n.t('opinions.form.confirm')}</p>;
        }
        return (
            <div>
                <span className={`fa fa-${this.iconForSide()} opinion-icon opinion-icon-${this.props.currentVote}`} />
                <div className="box">
                    <section>
                        {confirmHeader}
                        <div className="markdown" itemProp="text">
                            <p>{explanation}</p>
                        </div>
                        <div className="opinion-body__arguments-list">
                            {argumentFields['pro'].map(result => { return <a href={result.url} key={result.value}><label className="pro-t">{result.label}</label></a>; })}
                        </div>
                        <div className="opinion-body__arguments-list">
                            {argumentFields['con'].map(result => { return <a href={result.url} key={result.value}><label className="con-t">{result.label}</label></a>; })}
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
