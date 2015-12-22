/**
 * Update module.
 * Not to be confused with application updates, these are for the data model `Update`
 * @module Update
 * @author Fletcher91 <thom@argu.co>
 */

import React from 'react';
import RProfile from '../records/RProfile';
import Profile from './Profile';


import { Provider, connect } from 'react-redux';
import { liveStore } from '../stores/store';

function mapStateToProps(state) {
    return {
        profiles: state.profiles,
        updates: state.updates
    }
}

export const UpdateContainerWrapper = React.createClass({
    render: function render() {
        return (<Provider store={liveStore()}>
            <UpdateContainer updateId={this.props.updateId} />
        </Provider>);
    }
});
window.UpdateContainerWrapper = UpdateContainerWrapper;

export default UpdateContainerWrapper;

let UpdateContainer = React.createClass({
    render: function render() {
        const { updates, profiles, updateId } = this.props;

        const update = updates
            .find(update => {
            return update.id === updateId;
        });

        const creator = profiles
            .find(profile => {
            return profile.id === update.creatorId;
        });

        return (<Update creator={creator}
                        update={update}
                        {...update} />);
    }
});
UpdateContainer = connect(mapStateToProps)(UpdateContainer);
window.UpdateContainer = UpdateContainer;

export const Update = React.createClass({
    propTypes: {
        update: React.PropTypes.object
    },

    profile: function () {
        const { update, creator } = this.props;
        if (typeof creator !== 'undefined') {
            return <Profile profile={creator}
                            resource={update} />
        }
    },

    dateInText: function (date) {
        if (typeof date === 'string') {
            return date;
        } else {
            return date && date.toLocaleDateString();
        }
    },

    render: function render() {
        const { update } = this.props;
        const title = update.get('title');
        const content = update.get('content');
        const date = update.getIn(['dateline', 'date']);

        const profile = this.profile();
        const dateText = this.dateInText(date);

        return (
            <div className="box update" style={{width: '100%'}}>
                <section className="section-info update-bg">
                    <span className="fa fa-clock-o"/>
                    <span className="icon-left">_Update_</span>
                    <span className="icon-left">{dateText}</span>
                </section>
                <section>
                    <h3>{title}</h3>
                    <p>{content}</p>
                </section>
                {profile}
            </div>
        );
    }
});
window.Update = Update;
