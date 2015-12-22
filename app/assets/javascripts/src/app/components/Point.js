import React, { Component } from 'react';
import { bindActionCreators } from 'redux';
import { connect }  from 'react-redux';

import { Link } from '../lib/Link';
import * as actions from '../actions/point';

const PointContainerComponent = React.createClass({
    propTypes: {
        pointId: React.PropTypes.number
    },

    setActive: function setActive (e) {
        const { pointId, actions } = this.props;
        console.log('setactive clicked');
        actions.setActivePoint(pointId);
    },

    render: function render () {
        const { pointId } = this.props;

        return (<Link onClick={this.setActive}
                      query={{'timeline[activePointId]': pointId}}>
            U
        </Link>);
    }
});

function mapState (state) {
    const { timelines, points } = state;

    return {
        timelines,
        points
    };
}

function mapDispatch (dispatch) {
    return {
        actions: bindActionCreators(actions, dispatch)
    }
}

const PointContainer = connect(mapState, mapDispatch)(PointContainerComponent);
window.PointContainer = PointContainer;
export default PointContainer;


/**
 * Represents a Point on a {@link TimeLine}.
 * @class Point
 * @author Fletcher91 <thom@argu.co>
 */
export const Point = React.createClass({
    propTypes: {
        point: React.PropTypes.object,
        actions: React.PropTypes.object
    },

    render: function render() {
        const { active, setActive } = this.props;

        //const style = {
        //    flexGrow: 1,
        //    border: active ?  '1px solid yellow' : undefined
        //};

        //return (
        //    <Link to="" />
        //);
        //
        //return (<a href=""
        //           className={`point ${this.props.active}`}
        //           onClick={this.setActive}
        //           style={style}>U</a>);
    }
});
window.Point = Point;
