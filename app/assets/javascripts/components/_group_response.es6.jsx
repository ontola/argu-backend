window.BigGroupResponse = React.createClass({
    getInitialState: function () {
        return {
            object_type: this.props.object_type,
            object_id: this.props.object_id,
            current_vote: this.props.current_vote,
            distribution: this.props.distribution,
            percent: this.props.percent
        };
    },

    refresh: function () {
        fetch(`${this.state.object_id}.json`, _safeCredentials())
            .then(status)
            .then(json)
            .then((data)  => {
                data.motion && this.setState(data.motion);
            }).catch(() => {
                Argu.Alert('_Er is iets fout gegaan, probeer het opnieuw._', 'alert', true);
            });
    },

    render: function () {
        return (<div className="motion-shr">
            {this.props.groups.map((group) => {
                let respond, buttons;
                if (group.responses_left > 0) {
                    respond = (<p className="group-response-pre center">Stem namens {this.props.actor.name} als {group.name_singular}:</p>);
                    buttons = (
                        <ul className="btns-opinion center">
                            <li><a href={`${this.props.object_id}/groups/${group.id}/responses/new?side=pro`} rel="nofollow" className="btn-pro">
                                <span className="fa fa-thumbs-up" />
                                <span className="icon-left">Voor</span>
                            </a></li>
                            <li><a href={`${this.props.object_id}/groups/${group.id}/responses/new?side=neutral`} rel="nofollow" className="btn-neu">
                                <span className="fa fa-pause" />
                                <span className="icon-left">Geen van beiden</span>
                            </a></li>
                            <li><a href={`${this.props.object_id}/groups/${group.id}/responses/new?side=con`} rel="nofollow" className="btn-con">
                                <span className="fa fa-thumbs-down" />
                                <span className="icon-left">Tegen</span>
                            </a></li>
                        </ul>
                    );
                }

                let responses;
                if (group.actor_group_responses.length > 0) {
                    responses = group.actor_group_responses.map((response) => {
                        return (
                            <div key={`group_responses_${response.id}`}>
                                <div className="box response" id="group_responses_9">
                                    <section className="section-info {response.side}-bg">
                                        <span>
                                            {response.side}
                                        </span>
                                    </section>
                                    <section>
                                        <h3>
                                            {this.props.actor.name}
                                        </h3>
                                        <p>{response.text}</p>
                                        <ul className="btns-list--subtle btns-horizontal btn-sticky-bottom btn-sticky">
                                            <li>
                                                <a data-method="delete" data-remote="true" data-confirm="Dit object en alle bijbehorende data zal permanent verwijderd worden. Deze actie is niet ongedaan te maken." data-skip-pjax="true" href={`/group_responses/${response.id}`}>
                                                    <span className="fa fa-close"></span>
                                                    <span className="icon-left">Vernietigen</span>
                                                </a>
                                            </li>
                                            <li>
                                                <a href={`/group_responses/${response.id}/edit`}>
                                                    <span className="fa fa-pencil"></span>
                                                    <span className="icon-left">Bewerken</span>
                                                </a>
                                            </li>
                                        </ul>
                                    </section>
                                </div>
                            </div>
                        );
                        }
                    );
                }

                return (<div key={group.id}>
                    {respond}
                    {buttons}
                    {responses}
                </div>);
            })}
        </div>);
    }
});

if (typeof module !== 'undefined' && module.exports) {
    module.exports = BigGroupResponse;
}
