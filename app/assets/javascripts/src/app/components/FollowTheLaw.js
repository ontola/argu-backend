/**
 * Follow the law module.
 * @module FollowTheLaw
 * @author Fletcher91 <thom@argu.co>
 */

import React from 'react';
import { Record } from 'immutable';
import RPhase from '../records/RPhase';
import RUpdate from '../records/RUpdate';
import RProfile from '../records/RProfile';
import RTimeLine from '../records/RTimeLine';
import { Update, UpdateContainerWrapper } from './Update';


import { bindActionCreators } from 'redux'
import { Provider, connect } from 'react-redux';
import store from '../stores/store';
import * as TimeLineActions from '../actions/timeline'

function mapStateToProps(state) {
    return {
        timelines: state.timelines,
        updates: state.updates,
        phases: state.phases,
        points: state.points
    }
}

function mapDispatchToProps(dispatch) {
    return {
        actions: bindActionCreators(TimeLineActions, dispatch)
    };
}

/**
 * Store wrapper around the TimeLineComponentContainer until we have a router.
 * @class TimeLineComponentContainerWrapper
 * @author Fletcher91 <thom@argu.co>
 */
export const TimeLineComponentContainerWrapper = React.createClass({
    render: function render() {

        return (<Provider store={store}>
            <TimeLineComponentContainer timeLineId={this.props.timeLineId} />
        </Provider>);
    }
});
window.TimeLineComponentContainerWrapper = TimeLineComponentContainerWrapper;

/**
 * Store wrapper container
 * @class TimeLineComponentContainer
 * @author Fletcher91 <thom@argu.co>
 */
let TimeLineComponentContainer = React.createClass({
    render: function render() {
        const { timeLineId, timelines, phases, updates, points, actions } = this.props;

        const timeLine = new RTimeLine(timelines[timeLineId]);

        return (<div>
            <TimeLineComponent timeLine={timeLine}
                               phases={phases}
                               points={points}
                               updates={updates}
                               actions={actions} />
        </div>);
    }
});
TimeLineComponentContainer = connect(mapStateToProps, mapDispatchToProps)(TimeLineComponentContainer);
window.TimeLineComponentContainer = TimeLineComponentContainer;

/**
 * Main TimeLine class.
 * @class TimeLineComponent
 * @author Fletcher91 <thom@argu.co>
 */
export const TimeLineComponent = React.createClass({
    propTypes: {
        phases: React.PropTypes.array,
        points: React.PropTypes.array,
        timeLine: React.PropTypes.instanceOf(RTimeLine),
        updates: React.PropTypes.array
    },

    activePoint: function () {
        const { timeLine, points } = this.props;
        const { activePointId } = timeLine;

        if (typeof activePointId === 'undefined') {
            return undefined;
        }

        return points.find((elem) => {
                return elem.id === activePointId
            });
    },

    render: function render() {
        const { phases, timeLine, actions, updates, points } = this.props;
        const { currentPhase, phaseCount } = timeLine;

        const detailsPane = <DetailsPane point={this.activePoint()}
                                         phases={phases}
                                         updates={updates} />;

        return (
            <div className="time-line-component" style={{display: 'flex', flexDirection: 'column'}}>
                <h2>Volg de wet</h2>
                <TimeLine
                    timeLine={timeLine}
                    actions={actions}
                    points={points}
                    updates={updates}
                    currentPhase={currentPhase}
                    phaseCount={phaseCount}
                    phases={phases} />
                {detailsPane}
            </div>
        );
    }
});
window.TimeLineComponent = TimeLineComponent;

/**
 * The actual line of the timeline.
 * @todo Rework so it only uses {@link Point}s
 * @class TimeLine
 * @author Fletcher91 <thom@argu.co>
 */
export const TimeLine = React.createClass({
    pointActive: function (point, activePointId) {
        return point.id === activePointId ? 'active' : undefined;
    },

    pointByItem: function pointByItem(itemType, itemId) {
        return this.props.points.find(point => {
                return point.type === itemType &&
                    point.itemId === itemId;
            });
    },

    pointsForPhase: function pointsForPhase(phaseId) {
        const { updates, timeLine, actions } = this.props;
        const { activePointId } = timeLine;

        if (typeof updates === 'undefined') {
            return undefined;
        }

        return updates
            .filter((update) => {
                return update.phaseId === phaseId;
            })
            .map((update) => {
                const point = this.pointByItem('update', update.id);
                return <Point key={point.id}
                              point={point}
                              active={this.pointActive(point, activePointId)}
                              actions={actions} />;
            });
    },

    render: function render() {
        const { actions, phases, timeLine } = this.props;
        const { id, activePointId, currentPhase } = timeLine;

        const phasesList = phases.map((phase, i) => {
            const itemUpdates = this.pointsForPhase(phase.id);
            const current = phase.id === currentPhase ? 'current' : '';
            const last  = i === phases.length - 1;
            const point = this.pointByItem('phase', phase.id);
            return (<Phase key={phase.id}
                           phase={new RPhase(phase)}
                           point={point}
                           active={this.pointActive(point, activePointId)}
                           current={current}
                           last={last}
                           timelineId={id}
                           actions={actions}>
                {itemUpdates}
            </Phase>);
        });

        return (
            <div className="time-line" style={{display: 'flex', flexDirection: 'row'}}>
                {phasesList}
            </div>
        );
    }
});
window.TimeLine = TimeLine;


/**
 * That thing beneath a {@link TimeLine} when you click on a {@link Point}.
 * @class DetailsPane
 * @author Fletcher91 <thom@argu.co>
 */
export const DetailsPane = React.createClass({
    pointActive: function (point, activePointId) {
        return point.id === activePointId ? 'active' : undefined;
    },

    render: function render() {
        const { phases, point, updates} = this.props;

        if (typeof point === 'undefined') {
            return <div></div>;
        }

        const collections = {
            phase: phases,
            update: updates
        };
        const phase = collections[point.type].find(elem => {
            return elem.id === point.itemId
        });

        if (point.type === 'update') {
            return <UpdateContainerWrapper updateId={point.itemId}
                                           {...phase} />;
        } else {
            // We're mocking an `RUpdate` here since we're hacking this from a phase description
            return <Update update={new RUpdate()}
                           {...phase} />;
        }
    }
});
window.DetailsPane = DetailsPane;

/**
 * Represents a Phase within a {@link TimeLine}
 * Also renders all its children updates as {@link Point}s.
 * @class Phase
 * @author Fletcher91 <thom@argu.co>
 */
export const Phase = React.createClass({
    propTypes: {
        phase: React.PropTypes.instanceOf(RPhase),
        point: React.PropTypes.object,
        actions: React.PropTypes.object,
        last: React.PropTypes.bool
    },

    getLabel: function () {
        const { last, phase } = this.props;
        const { title } = phase;

        if (!last) {
            return <span className="phase-title" style={{textAlign: 'center'}}>{title}</span>
        } else {
            return <span style={{flex: 1}}></span>;
        }
    },

    render: function render() {
        const { actions, point, current, last, active } = this.props;

        const label = this.getLabel();
        return (
            <div className={`phase ${current}`} style={{display: 'flex', flexDirection: 'column', flexGrow: last ? 0 : 1}}>
                {label}
                <div className="phase-points" style={{display: 'flex', flexDirection: 'row'}}>
                    <PhasePoint point={point}
                                active={active}
                                actions={actions}
                                current={current} />
                    {this.props.children}
                </div>
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
        point: React.PropTypes.object,
        actions: React.PropTypes.object
    },

    setActive: function setActive() {
        const { id, timelineId } = this.props.point;
        this.props.actions.setActivePoint(timelineId, id);
    },

    render: function render() {
        return (<span className={`point ${this.props.active}`}
                      onClick={this.setActive}
                      style={{flexGrow: 1}}>U</span>);
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
        title: React.PropTypes.string,
        point: React.PropTypes.object
    },

    setActive: function makeActive() {
        const { id, timelineId } = this.props.point;
        this.props.actions.setActivePoint(timelineId, id);
    },

    render: function render() {
        const { current, active } = this.props;

        return (
            <span className={`point phase-point ${current} ${active}`}
                  onClick={this.setActive}
                  style={{flexGrow: 1}}>P</span>
        );
    }
});
window.PhasePoint = PhasePoint;

export default TimeLineComponentContainer;
