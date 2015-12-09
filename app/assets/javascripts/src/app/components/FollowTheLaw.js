/**
 * Follow the law module.
 * @module FollowTheLaw
 * @author Fletcher91 <thom@argu.co>
 */

import React from 'react';
import { Record } from 'immutable';
import RPhase from '../records/RPhase';
import RUpdate from '../records/RUpdate';
import RTimeLine from '../records/RTimeLine';

import { Provider, connect } from 'react-redux';
import store from '../stores/store';

function mapStateToProps(state) {
    return {
        timelines: state.timelines,
        updates: state.updates,
        phases: state.phases
    }
}

/**
 * Store wrapper around the TimeLineComponentContainer until we have a router.
 * @class TimeLineComponentContainerWrapper
 * @author Fletcher91 <thom@argu.co>
 */
export const TimeLineComponentContainerWrapper = React.createClass({
    render: function render() {
        window.timeLineStore = store;

        return (<Provider store={store}>
            <TimeLineComponentContainer timeLineId={this.props.timeLineId} />
        </Provider>);
    }
});
window.TimeLineComponentContainerWrapper = TimeLineComponentContainerWrapper;

/**
 * Store wrapper container
 * @class TimeLineComponentContainerr
 * @author Fletcher91 <thom@argu.co>
 */
let TimeLineComponentContainer = React.createClass({
    render: function render() {
        const { timeLineId, timelines } = this.props;

        debugger;
        const timeLine = timelines.get(timeLineId);

        return (<div>
            <TimeLineComponent timeLine={timeLine} />
        </div>);
    }
});
TimeLineComponentContainer = connect(mapStateToProps)(TimeLineComponentContainer);
window.TimeLineComponentContainer = TimeLineComponentContainer;

/**
 * Main TimeLine class.
 * @class TimeLineComponent
 * @author Fletcher91 <thom@argu.co>
 */
export const TimeLineComponent = React.createClass({
    propTypes: {
        timeLine: React.PropTypes.instanceOf(RTimeLine)
    },

    render: function render() {
        const { phases, updates, parentUrl, currentPhase, phaseCount } = this.props.timeLine;

        let phasesList = phases.map((phase, i) => {
            let itemUpdates;
            if (typeof updates !== 'undefined') {
                itemUpdates = updates
                    .filter((update) => {
                        return update.phaseId === phase.id;
                    })
                    .map((update) => {
                        return <Point key={update.id} title={update.title} />;
                    });
            }
            return (<Phase key={phase.id} phase={phase}>
                {itemUpdates}
            </Phase>);
        });

        return (
            <div className="time-line-component" style={{display: 'flex', flexDirection: 'column'}}>
                <h2>Follow the law</h2>
                <TimeLine
                    parentUrl={parentUrl}
                    currentPhase={currentPhase}
                    phaseCount={phaseCount}
                    phases={phases}>
                    {phasesList}
                </TimeLine>
            </div>
        );
    }
});
window.TimeLineComponent = TimeLineComponent;

/**
 * The actual line of the timeline.
 * @class TimeLine
 * @author Fletcher91 <thom@argu.co>
 */
export const TimeLine = React.createClass({
    render: function render() {
        return (
            <div className="time-line" style={{display: 'flex', flexDirection: 'row'}}>
                {this.props.children}
            </div>
        );
    }
});
window.TimeLine = TimeLine;

/**
 * Represents a Phase within a {@link TimeLine}
 * @class Phase
 * @author Fletcher91 <thom@argu.co>
 */
export const Phase = React.createClass({
    propTypes: {
        phase: React.PropTypes.instanceOf(RPhase)
    },

    render: function render() {
        const { title } = this.props.phase;

        return (
            <div className="phase" style={{display: 'flex', flexGrow: 1}}>
                <PhasePoint title={title} />
                {this.props.children}
            </div>
        );
    }
});
window.Phase = Phase;

/**
 * Represents a Point on a {@link TimeLine}.
 * @class Point
 * @author Fletcher91 <thom@argu.co>
 */
export const Point = React.createClass({
    propTypes: {
        title: React.PropTypes.string
    },
    render: function render() {
        return (
            <span className="point" style={{flexGrow: 1}} >P</span>
        );
    }
});
window.Point = Point;

/**
 * To display a Phase point on a {@link TimeLine}
 * @class PhasePoint
 * @author Fletcher91 <thom@argu.co>
 */
export const PhasePoint = React.createClass({
    propTypes: {
        phase: React.PropTypes.instanceOf(RPhase)
    },
    render: function render() {
        const { title } = this.props.phase;

        return (
            <span className="point phase-point" style={{flexGrow: 1}} >
                <span className="point-title phase-point-title">{title}</span>
            </span>
        );
    }
});
window.PhasePoint = PhasePoint;

export default TimeLineComponentContainer;
