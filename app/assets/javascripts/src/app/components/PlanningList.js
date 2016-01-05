import React from 'react';
import { connect } from 'react-redux';

/**
 * Shows a list of the current plannings.
 * @class PlanningListContainerComponent
 * @author Fletcher91 <thom@argu.co>
 */
const PlanningListContainerComponent = React.createClass({

    render: function render () {
        return <PlanningList {...this.props} />;
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

const PlanningListContainer = connect(mapState)(PlanningListContainerComponent);
window.PlanningListContainer = PlanningListContainer;
export default PlanningListContainer;

/**
 * Shows a list of the current plannings.
 * @class PlanningList
 * @author Fletcher91 <thom@argu.co>
 * @param {List.Planning} plannings
 */
const PlanningList = React.createClass({


    render: function render () {
        const { plannings } = this.props;
        const planningComponents = plannings && plannings
                .get('collection')
                .map(planning => {
            return <PlanningListItem key={planning.get('id')} planning={planning} />;
        });

        return (
            <div className="planning-list">
                {planningComponents}
            </div>
        );
    }
});

/**
 * Shows a Planning as a list item.
 * @class PlanningListItem
 * @author Fletcher91 <thom@argu.co>
 */
const PlanningListItem = React.createClass({
    propTypes: {
        planning: React.PropTypes.object
    },

    render: function render () {
        const { planning } = this.props;

        return (
            <div className="planning-item">
                <h3>{planning.get('title')}</h3>
            </div>
        );
    }
});
