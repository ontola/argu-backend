import React from 'react'
import I18n from 'i18n-js';

const OpinionShow = React.createClass({
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
        const { actor, currentExplanation: { explanation_html, explained_at }, onOpenOpinionForm, selectedArguments } = this.props;
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
            confirmHeader = <p className="unconfirmed-vote-warning">{I18n.t('opinions.form.confirm_notice')} <strong>{actor.confirmationEmail}</strong>.</p>;
        }
        return (
            <div>
                <span className={`fa fa-${this.iconForSide()} opinion-icon opinion-icon-${this.props.currentVote}`} />
                <div className="box">
                    <section>
                        {confirmHeader}
                        <div className="markdown" dangerouslySetInnerHTML={{ __html: explanation_html }} itemProp="text"/>
                        <div className="opinion-body__arguments-list">
                            {argumentFields['pro'].map(result => { return <a data-remote="true" href={result.url} key={result.value}><label className="pro-t">{result.label}</label></a>; })}
                        </div>
                        <div className="opinion-body__arguments-list">
                            {argumentFields['con'].map(result => { return <a data-remote="true" href={result.url} key={result.value}><label className="con-t">{result.label}</label></a>; })}
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

export default OpinionShow;
