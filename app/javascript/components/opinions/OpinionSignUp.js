import React from 'react'
import I18n from 'i18n-js';
import { getAuthenticityToken } from '../lib/helpers';

export const OpinionSignUp = React.createClass({
    propTypes: {
        facebookUrl: React.PropTypes.string.isRequired,
        onSignupEmailChange: React.PropTypes.func.isRequired,
        onSubmitRegistration: React.PropTypes.func.isRequired,
        signupEmail: React.PropTypes.string.isRequired,
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
        const { facebookUrl, onSignupEmailChange, signupEmail, submitting } = this.props;
        return (
            <form className={`formtastic formtastic--full-width ${submitting ? 'is-loading' : ''}`} onSubmit={this.props.onSubmitRegistration}>
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

export default OpinionSignUp;
