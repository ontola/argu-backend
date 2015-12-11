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
import store from '../stores/store';

function mapStateToProps(state) {
    return {
        profiles: state.profiles,
        updates: state.updates
    }
}

export const UpdateContainerWrapper = React.createClass({
    render: function render() {
        return (<Provider store={store}>
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
        id: React.PropTypes.number,
        title: React.PropTypes.string,
        content: React.PropTypes.string,
        creator: React.PropTypes.object,
        dateline: React.PropTypes.object
    },

    profile: function () {
        const { update, creator } = this.props;
        if (typeof creator !== 'undefined') {
            return <Profile profile={creator}
                            resource={update} />
        }
    },

    render: function render() {
        const { title, content, dateline } = this.props;

        const profile = this.profile();

        const date = dateline && dateline.date;
        return (
            <div className="box update" style={{width: '100%'}}>
                <section className="section-info update-bg">
                    <span className="fa fa-clock-o"/>
                    <span className="icon-left">_Update_</span>
                    <span className="icon-left">{date}</span>
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
