import React from 'react'
import I18n from 'i18n-js';

import { getAuthenticityToken } from '../lib/helpers';
import Footer from '../forms/Footer';

export const OpinionSignUp = React.createClass({
    propTypes: {
        errorMessage: React.PropTypes.string,
        facebookUrl: React.PropTypes.string.isRequired,
        forgotPassword: React.PropTypes.object.isRequired,
        loginStep: React.PropTypes.string.isRequired,
        onCancelLogin: React.PropTypes.func.isRequired,
        onSignupEmailChange: React.PropTypes.func.isRequired,
        onSignupPasswordChange: React.PropTypes.func.isRequired,
        onSubmitEmail: React.PropTypes.func.isRequired,
        policyPath: React.PropTypes.bool.isRequired,
        signupEmail: React.PropTypes.string.isRequired,
        signupPassword: React.PropTypes.string.isRequired,
        submitting: React.PropTypes.bool.isRequired
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
        let errorMessage, footer, form;
        const { onCancelLogin, submitting } = this.props;
        if (this.props.errorMessage) {
            errorMessage = <div className="inline-errors">{this.props.errorMessage}</div>
        }

        const signupEmailField = <input
            name="user[email]"
            className="form-input-content"
            onChange={this.props.onSignupEmailChange}
            placeholder={I18n.t('opinions.form.email.placeholder')}
            type="email"
            value={this.props.signupEmail}/>;

        switch (this.props.loginStep) {
        case 'initial':
            form = <div>
                <div className="formtastic--full-width"><label>{I18n.t('opinions.form.signup')}</label></div>
                {signupEmailField}
                <button type="submit" disabled={submitting}>{I18n.t('opinions.form.continue')}</button>
                <div className="margin-bottom">
                    <label className="inline">{I18n.t('opinions.form.or')}&nbsp;</label>
                    <a className="btn btn--facebook" data-turbolinks="false" href={this.props.facebookUrl}>
                        <span className="fa fa-facebook" />
                        <span className="icon-left">{I18n.t('opinions.form.facebook_login')}</span>
                    </a>
                    <div className="info">&nbsp;{I18n.t('opinions.form.facebook_notice')}</div>
                </div>
            </div>;
            break;
        case 'login':
            form = <div>
                <div className="formtastic--full-width"><p>{I18n.t('opinions.form.welcome_back')}</p></div>
                <label>{I18n.t('formtastic.labels.email')}</label>
                {signupEmailField}
                <label>{I18n.t('formtastic.labels.password')}</label>
                <input
                    autoFocus
                    className="form-input-content"
                    name="user[password]"
                    onChange={this.props.onSignupPasswordChange}
                    placeholder={I18n.t('opinions.form.password.placeholder')}
                    type="password"
                    value={this.props.signupPassword}/>
                {errorMessage}
                <div className="btns-devise">
                    <a href={this.props.forgotPassword.href} target="_blank">{this.props.forgotPassword.text}</a>
                </div>
            </div>;

            footer = <Footer cancelButton={I18n.t('opinions.form.cancel')} disabled={submitting} onCancel={onCancelLogin} submitButton={I18n.t('opinions.form.login')}/>;
            break;
        case 'register':
            form = <div>
                <p>{I18n.t('legal.notice')}<a href={this.props.policyPath} target="_blank">{I18n.t('legal.documents.policy')}.</a></p>
                {signupEmailField}
            </div>;

            footer = <Footer cancelButton={I18n.t('opinions.form.cancel')} disabled={submitting} onCancel={onCancelLogin} submitButton={I18n.t('opinions.form.confirm')}/>;
            break;
        }

        return <form className={`formtastic${submitting ? ' is-loading' : ''}`} onSubmit={this.props.onSubmitEmail}>
            <input type="hidden" name="authenticity_token" value={this.state.authenticityToken}/>
            <input type="hidden" name="user[r]" value={this.state.currentUrl}/>
            <div className="box">
                <section>{form}</section>
                {footer}
            </div>
        </form>;
    }
});

export default OpinionSignUp;
