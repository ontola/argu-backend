import React from 'react';
import { Provider, connect } from 'react-redux';

import { liveStore } from '../stores/store';
import PlanningListContainer from './PlanningList';
import Link from '../lib/Link';

/**
 * Store wrapper around the PlanningForumSettingsContainer until we have a router.
 * @class PlanningForumSettingsContainerWrapper
 * @author Fletcher91 <thom@argu.co>
 */
export const PlanningForumSettingsContainerWrapper = React.createClass({
    render: function render() {

        return (<Provider store={liveStore()}>
            <PlanningForumSettingsContainer />
        </Provider>);
    }
});
window.PlanningForumSettingsContainerWrapper = PlanningForumSettingsContainerWrapper;


/**
 * Shows a list of the current plannings.
 * @class PlanningForumSettingsContainerComponent
 * @author Fletcher91 <thom@argu.co>
 */
const PlanningForumSettingsContainerComponent = React.createClass({

    render: function render () {
        return (
            <div>
                <h2>Plannings settings</h2>
                <PlanningListContainer />
                <Link href="" isButton={true} >
                    Add Planning
                </Link>
            </div>
        );
    }
});

function mapState (state) {
    const { plannings } = state;

    return {
        plannings
    };
}

//function mapDispatch (dispatch) {
//    return {
//        actions: bindActionCreators(actions, dispatch)
//    }
//}

const PlanningForumSettingsContainer = connect(mapState)(PlanningForumSettingsContainerComponent);
window.PlanningForumSettingsContainer = PlanningForumSettingsContainer;
export default PlanningForumSettingsContainer;
