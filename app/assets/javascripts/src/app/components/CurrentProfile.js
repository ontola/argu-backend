import React from 'react';
import { image } from '../lib/helpers';
import actorStore from '../stores/actor_store';

export const CurrentProfile = React.createClass({
    getInitialState: function () {
        return {
            display_name: this.props.display_name,
            profile_photo: this.props.profile_photo
        };
    },

    onActorChange: function (data) {
        this.setState(data);
    },

    componentDidMount: function () {
        this.unsubscribe = actorStore.listen(this.onActorChange);
    },

    componentWillUnmount: function () {
        this.unsubscribe();
    },

    render: function () {

        return (<section className="profile-small inspectlet-sensitive">
            {image({image: this.state.profile_photo})}
            <div className="info-block">
                <div className="info">plaatsen als:</div>
                <div className="profile-name">{this.state.display_name}</div>
            </div>
        </section>);
    }
});

window.CurrentProfile = CurrentProfile;
