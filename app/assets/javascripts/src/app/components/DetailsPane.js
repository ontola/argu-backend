import React, { Component } from 'react';
import { bindActionCreators } from 'redux';
import { connect }  from 'react-redux';

import { Update, UpdateContainerWrapper } from './Update';
import { Link } from '../lib/Link';
import * as actions from '../actions/point';

/**
 * Shows a {@link DetailsPane} of the currently active point thus $points.activePoint
 * @class DetailsPane
 * @author Fletcher91 <thom@argu.co>
 */
const DetailsPaneContainerComponent = React.createClass({

    /**
     * Searches the current active point from the components props.
     * @returns {RPoint}
     */
    activePoint: function activePoint () {
        const { points } = this.props;
        return points && points.get('activePoint');
    },

    /**
     * Searches the currently active object from the active RPoint.
     * @returns {RUpdate|RPhase}
     */
    activeItem: function activeItem () {
        const activePoint = this.activePoint();
        if (activePoint === null) {
            return undefined;
        }
        const collections = {
            phase: this.props.phases,
            update: this.props.updates
        };

        return collections[activePoint.itemType].find(elem => {
            return elem.id === activePoint.itemId
        });
    },

    render: function render () {
        const activePoint = this.activePoint();


        return (<DetailsPane item={this.activeItem()}
                             point={activePoint} />);
    }
});

function mapState (state) {
    const { points, phases, updates } = state;

    return {
        points,
        phases,
        updates
    };
}

function mapDispatch (dispatch) {
    return {
        actions: bindActionCreators(actions, dispatch)
    }
}

const DetailsPaneContainer = connect(mapState, mapDispatch)(DetailsPaneContainerComponent);
window.DetailsPaneContainer = DetailsPaneContainer;
export default DetailsPaneContainer;


/**
 * That thing beneath a {@link TimeLine} when you click on a {@link Point}.
 * @class DetailsPane
 * @author Fletcher91 <thom@argu.co>
 */
export const DetailsPane = React.createClass({
    propTypes: {
        actions: React.PropTypes.object,
        item: React.PropTypes.object,
        point: React.PropTypes.object
    },

    style: {
        display: 'flex',
        alignItems: 'center'
    },

    nextItem: function () {
        const { timelineId } = this.props.point;
        this.props.actions.nextPoint(timelineId);
    },

    previousItem: function () {
        const { timelineId } = this.props.point;
        this.props.actions.previousPoint(timelineId);
    },

    render: function render() {
        const { item, point } = this.props;

        if (typeof item === 'undefined') {
            return <div></div>;
        }

        const UpdateItem = point.itemType === 'update' ?
            <UpdateContainerWrapper updateId={item.get('id')} /> :
            <Update update={new RUpdate(item)} />;

        return (<div className="details-pane" style={this.style}>
            <span className="details-pane-previous"
                  style={{fontSize: '2em'}}
                  onClick={this.previousItem}>&lt;</span>
            {UpdateItem}
            <span className="details-pane-next"
                  style={{fontSize: '2em'}}
                  onClick={this.nextItem}>&gt;</span>
        </div>);
    }
});
window.DetailsPane = DetailsPane;
