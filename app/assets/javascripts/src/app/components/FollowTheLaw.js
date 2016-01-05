/**
 * Follow the law module.
 * @module FollowTheLaw
 * @author Fletcher91 <thom@argu.co>
 */

import React from 'react';
import { List, Map } from 'immutable';

import RPhase from '../records/RPhase';
import RTimeline from '../records/RTimeline';
import PointContainer from './Point';
import DetailsPaneContainer from './DetailsPane';


import { bindActionCreators } from 'redux';
import { Provider, connect } from 'react-redux';
import { liveStore } from '../stores/store';
import * as TimeLineActions from '../actions/timeline';

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

        return (<Provider store={liveStore()}>
            <TimeLineComponentContainer timelineId={this.props.timelineId} />
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
        const { timelineId, timelines, phases, updates, points, actions } = this.props;

        let timelineComponent;
        if (typeof timelineId !== 'undefined') {
            const timeline = timelines.getIn(['collection', timelineId.toString()]);
            if (typeof timeline !== 'undefined') {
                timelineComponent = <TimeLineComponent timeline={timeline}
                                                       phases={phases}
                                                       points={points}
                                                       updates={updates}
                                                       actions={actions} />;
            }
        }

        return (<div>
            {timelineComponent}
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
        phases: React.PropTypes.instanceOf(List),
        points: React.PropTypes.instanceOf(Map),
        timeline: React.PropTypes.instanceOf(RTimeline),
        updates: React.PropTypes.instanceOf(List)
    },

    style: {
        display: 'flex',
        flexDirection: 'column'
    },

    currentPhaseItem: function () {
        const { currentPhase } = this.props.timeline;
        return this.props.phases.find(phase => {
            return phase.id === currentPhase;
        });
    },

    render: function render() {
        const { phases, timeline, actions, updates, points } = this.props;
        const phaseCount = 0 ;//timeline.get('phaseCount');
        const currentPhaseItem = this.currentPhaseItem();

        return (
            <div className="time-line-component" style={this.style}>
                <h2>Volg de wet</h2>
                <TimeLinePhases
                    timeline={timeline}
                    actions={actions}
                    points={points}
                    updates={updates}
                    phases={phases} />
                <TimeLine phaseCount={phaseCount}
                          currentPhaseIndex={currentPhaseItem && currentPhaseItem.index} />
                <DetailsPaneContainer />
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
    style: {
        display: 'flex',
        flexDirection: 'row'
    },

    pointActive: function (point, activePointId) {
        return point.id === activePointId ? 'active' : undefined;
    },

    pointByItem: function pointByItem(itemType, itemId) {
        return this.props.points.get('collection').find(point => {
            return point.itemType === itemType &&
                point.itemId === itemId;
        });
    },

    pointsForPhase: function pointsForPhase(phaseId) {
        const { updates } = this.props;

        if (typeof updates === 'undefined') {
            return undefined;
        }

        return updates
            .filter((update) => {
                return update.phaseId === phaseId;
            })
            .map((update) => {
                const point = this.pointByItem('update', update.id);
                return <PointContainer key={point.id}
                                       pointId={point.id} />;
            });
    },

    render: function render() {
        const { actions, phases, timeline } = this.props;
        const { id, activePointId, currentPhase } = timeline;

        const phasesList = phases.map((phase, i) => {
            const itemUpdates = this.pointsForPhase(phase.id);
            const current = phase.id === currentPhase ? 'current' : '';
            const last = i === phases.length - 1;
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
            <div className="time-line-phases" style={this.style}>
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

    style: {
        width: '100%',
        height: 1,
        border: 0,
        borderTop: '3px solid #CCC',
        padding: 0,
        marginTop: '-.6em',
        zIndex: 1,
        marginBottom: '.6em'
    },

    render: function render() {
        const innerStyle = Object.assign({},
            this.style,
            {
                width: this.completionWidth(),
                borderTop: '3px solid #8BAACA',
                marginTop: '-.2em',
                zIndex: 2
            }
        );

        return (
            <div className="time-line" style={this.style}>
                <div className="inner-line" style={innerStyle}></div>
            </div>
        );
    }
});
window.TimeLinePhases = TimeLinePhases;

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
        last: React.PropTypes.bool,
        current: React.PropTypes.string
    },

    style: {
        display: 'flex',
        flexDirection: 'row'
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
        const { point, current, last } = this.props;

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
                <div className="phase-points" style={this.style}>
                    <PointContainer className={current}
                                    pointId={point.get('id')}/>
                    {this.props.children}
                </div>
            </div>
        );
    }
});
window.Phase = Phase;

export default TimeLineComponentContainer;
