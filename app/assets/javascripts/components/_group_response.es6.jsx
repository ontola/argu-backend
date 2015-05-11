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
        $.ajax({
            type: 'GET',
            url: this.state.object_id,
            dataType: 'json',
            async: true,
            success: (data) => {
                console.log('success', data);
                if (data.motion) {
                    this.setState(data.motion);
                }
            },
            error: function () {
                Argu.Alert('_Er is iets fout gegaan, probeer het opnieuw._', 'alert', true);
            }
        });
    },

    render: function () {
        console.log(this.props);
        console.log(this.state);
        return (<div className="center motion-shr">
            {this.props.groups.map((group) => {
                let respond, buttons;
                if (group.responses_left > 0) {
                    respond = (<p>Stem namens {this.props.actor.name} als {group.name_singular}</p>);
                    buttons = (
                        <ul className="btns-opinion">
                            <li><a href={`${this.props.object_id}/groups/${group.id}/responses/new?side=pro`} rel="nofollow" className="btn-pro">
                                <span className="fa fa-thumbs-up" />
                                <span className="icon-left">_Pro_</span>
                            </a></li>
                            <li><a href={`${this.props.object_id}/groups/${group.id}/responses/new?side=neutral`} rel="nofollow" className="btn-neu">
                                <span className="fa fa-pause" />
                                <span className="icon-left">_Neutral_</span>
                            </a></li>
                            <li><a href={`${this.props.object_id}/groups/${group.id}/responses/new?side=con`} rel="nofollow" className="btn-con">
                                <span className="fa fa-thumbs-down" />
                                <span className="icon-left">_Con_</span>
                            </a></li>
                        </ul>
                    );
                }

                return (<div key={group.id}>
                    {respond}
                    {buttons}
                </div>);
            })}
        </div>);
    }
});

if (typeof module !== 'undefined' && module.exports) {
    module.exports = BigGroupResponse;
}