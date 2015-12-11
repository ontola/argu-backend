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

    activeItem: function activeItem () {
        const activePoint = this.activePoint();
        if (typeof activePoint === 'undefined') {
            return undefined;
        }
        const collections = {
            phase: this.props.phases,
            update: this.props.updates
        };

        return collections[activePoint.type].find(elem => {
            return elem.id === activePoint.itemId
        });
    },

    currentPhaseItem: function () {
        const { currentPhase } = this.props.timeLine;
        return this.props.phases.find(phase => {
            return phase.id === currentPhase
        });
    },

    detailsPane: function detailsPane () {
        const activePoint = this.activePoint();
        if (typeof activePoint !== 'undefined') {
            return <DetailsPane item={this.activeItem()}
                                itemType={activePoint.type} />;
        }
    },

    render: function render() {
        const { phases, timeLine, actions, updates, points } = this.props;
        const { phaseCount } = timeLine;

        const activePoint = this.activePoint();
        if (typeof activePoint !== 'undefined') {

        }
        const detailsPane = this.detailsPane();
        const currentPhaseItem = this.currentPhaseItem();

        return (
            <div className="time-line-component" style={{display: 'flex', flexDirection: 'column'}}>
                <h2>Volg de wet</h2>
                <TimeLinePhases
                    timeLine={timeLine}
                    actions={actions}
                    points={points}
                    updates={updates}
                    phases={phases} />
                <TimeLine phaseCount={phaseCount}
                          currentPhaseIndex={currentPhaseItem.index} />
                {detailsPane}
            </div>
        );
    }
});
window.TimeLineComponent = TimeLineComponent;

/**
 * The display block for phases and their accompanying updates in order.
 * @todo Rework so it only uses {@link Point}s
 * @class TimeLine
 * @author Fletcher91 <thom@argu.co>
 */
export const TimeLinePhases = React.createClass({
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
            <div className="time-line-phases" style={{display: 'flex', flexDirection: 'row'}}>
                {phasesList}
            </div>
        );
    }
});
window.TimeLinePhases = TimeLinePhases;

/**
 * The actual line of the timeline.
 * @todo Rework so it only uses {@link Point}s
 * @class TimeLine
 * @author Fletcher91 <thom@argu.co>
 */
export const TimeLine = React.createClass({
    propTypes: {
        phaseCount: React.PropTypes.number,
        currentPhaseIndex: React.PropTypes.number
    },

    completionWidth: function completionWidth() {
        const phasePercentage = 100 / (this.props.phaseCount - 1);
        const width = (this.props.currentPhaseIndex * phasePercentage) + (phasePercentage / 2);
        return `${width}%`;
    },

    render: function render() {
        const style = {
            width: '100%',
            height: 1,
            border: 0,
            borderTop: '3px solid #CCC',
            padding: 0,
            marginTop: '-.6em',
            zIndex: 1,
            marginBottom: '.6em'
        };

        const innerStyle = Object.assign({},
            style,
            {
                width: this.completionWidth(),
                borderTop: '3px solid #8BAACA',
                marginTop: '-.2em',
                zIndex: 2
            }
        );

        return (
            <div className="time-line" style={style}>
                <div className="inner-line" style={innerStyle}></div>
            </div>
        );
    }
});
window.TimeLinePhases = TimeLinePhases;

/**
 * That thing beneath a {@link TimeLine} when you click on a {@link Point}.
 * @class DetailsPane
 * @author Fletcher91 <thom@argu.co>
 */
export const DetailsPane = React.createClass({
    render: function render() {
        const { item, itemType } = this.props;

        if (typeof item === 'undefined') {
            return <div></div>;
        }

        if (itemType === 'update') {
            return <UpdateContainerWrapper updateId={item.id}
                                           {...item} />;
        } else {
            // We're mocking an `RUpdate` here since we're hacking this from a phase description
            return <Update update={new RUpdate()}
                           {...item} />;
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
        const style = {
            display: 'flex',
            flexDirection: 'column',
            flexGrow: last ? 0 : 1,
            zIndex: 10
        };
        return (
            <div className={`phase ${current}`} style={style}>
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
        const { active } = this.props;
        let { id, timelineId } = this.props.point;
        if (active) {
            id = 0;
        }
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
        const { active } = this.props;
        let { id, timelineId } = this.props.point;
        if (active) {
            id = 0;
        }
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
