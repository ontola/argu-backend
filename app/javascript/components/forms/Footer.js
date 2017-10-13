import React from 'react'

const Footer = React.createClass({
    propTypes: {
        cancelButton: React.PropTypes.func.isRequired,
        disabled: React.PropTypes.bool.isRequired,
        onCancel: React.PropTypes.string.isRequired,
        submitButton: React.PropTypes.string.isRequired
    },

    render () {
        let cancelButton;
        if (this.props.cancelButton) {
            cancelButton = <li className="action button_action">
                    <button type="button" className="btn--transparant" onClick={this.props.onCancel}>
                        {this.props.cancelButton}
                    </button>
                </li>
        }
        return (
            <section className="section--footer">
                <fieldset className="actions">
                    <ol>
                        <div className="sticky-submit">
                            {cancelButton}
                            <li className="action button_action">
                                <button type="submit" disabled={this.props.disabled}>
                                    {this.props.submitButton}
                                </button>
                            </li>
                        </div>
                    </ol>
                </fieldset>
            </section>
        )
    }
});

export default Footer;
