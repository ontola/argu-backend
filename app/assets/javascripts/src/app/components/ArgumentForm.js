import React from 'react'
import I18n from 'i18n-js';

export const ArgumentForm = props => {
    return (
        <form className="formtastic formtastic--full-width argument-form" onSubmit={props.onSubmitArgument}>
            <div className="box">
                <section>
                    <div className="box form-toggle">
                        <ol className="choices-group">
                            <li className="choice">
                                <label className={`argument-pro ${props.createArgument.side === 'pro' ? 'checked' : ''}`}
                                       data-field="side"
                                       data-value="pro"
                                       onClick={props.onArgumentChange}>
                                    {I18n.t('arguments.form.side.pro')}
                                </label>
                            </li>
                            <li className="choice">
                                <label className={`argument-con ${props.createArgument.side === 'con' ? 'checked' : ''}`}
                                       data-field="side"
                                       data-value="con"
                                       onClick={props.onArgumentChange}>
                                    {I18n.t('arguments.form.side.con')}
                                </label>
                            </li>
                        </ol>
                    </div>
                    <label>{I18n.t('arguments.form.title_heading')}</label>
                    <textarea
                        autoFocus
                        className="form-input-content"
                        data-field="title"
                        name="argument-title"
                        onChange={props.onArgumentChange}
                        value={props.createArgument.title}/>
                    <label>{I18n.t('arguments.form.content_heading')}</label>
                    <textarea
                        className="form-input-content"
                        data-field="body"
                        name="argument-body"
                        onChange={props.onArgumentChange}
                        value={props.createArgument.body}/>
                </section>
                <section className="section--footer">
                    <fieldset className="actions">
                        <ol>
                            <div className="sticky-submit">
                                <li className="action button_action">
                                    <button className="btn--transparant" onClick={props.onCloseArgumentForm}>
                                        {I18n.t('opinions.form.cancel')}
                                    </button>
                                </li>
                                <li className="action button_action">
                                    <button type="submit" disabled={props.submitting}>
                                        {I18n.t('opinions.form.submit')}
                                    </button>
                                </li>
                            </div>
                        </ol>
                    </fieldset>
                </section>
            </div>
        </form>
    );
};
const ArgumentFormProps = {
    createArgument: React.PropTypes.object,
    onArgumentChange: React.PropTypes.func,
    onCloseArgumentForm: React.PropTypes.func,
    onSubmitArgument: React.PropTypes.func,
    submitting: React.PropTypes.bool
};
ArgumentForm.propTypes = ArgumentFormProps;

