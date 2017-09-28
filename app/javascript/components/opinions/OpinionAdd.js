import React from 'react'
import I18n from 'i18n-js';

const OpinionAdd = props => {
    const { actor, newExplanation, onOpenOpinionForm } = props;
    let confirmHeader;
    if (actor.confirmed === false) {
        confirmHeader = <p className="unconfirmed-vote-warning">{I18n.t('opinions.form.confirm_notice')} <strong>{actor.confirmationEmail}</strong>.</p>;
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

export default OpinionAdd;
