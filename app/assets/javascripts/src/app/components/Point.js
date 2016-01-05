import React from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import { Link } from '../lib/Link';
import * as actions from '../actions/point';

const PointContainerComponent = React.createClass({
    propTypes: {
        pointId: React.PropTypes.number,
        className: React.PropTypes.string
    },

    isActive: function isActive () {
        const { pointId, points } = this.props;
        return pointId === points.get('activePointId');
    },

    getPoint: function () {
        const { pointId, points } = this.props;
        return pointId && points
            .get('collection')
            .find(p => {
                return p.id === pointId
            });
    },

    getChild: function () {
        const point = this.getPoint();
        if (point === null) {
            return undefined;
        }

        const collections = {
            phase: this.props.phases,
            update: this.props.updates
        };

        return collections[point.itemType].find(elem => {
            return elem.id === point.itemId
        });
    },

    renderProps: function () {
        const {
            actions,
            className
        } = this.props;
        const point = this.getPoint();
        const child = this.getChild();
        const active = this.isActive();

        return {
            point,
            active,
            child,
            actions,
            className
        };
    },

    render: function render () {
        return (<Point {...this.renderProps()} />);
    }
});

function mapState (state) {
    const {
        points,
        updates,
        phases
    } = state;

    return {
        points,
        updates,
        phases
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
        child: React.PropTypes.object,
        actions: React.PropTypes.object
    },

    setActive: function setActive () {
        const { point, actions } = this.props;
        actions.setActivePoint(point.get('id'));
    },

    /**
     * @returns {UpdatePointMarker|PhasePointMarker} The current active point marker object.
     */
    getMarker: function getMarker() {
        const { child } = this.props;

        const type = child && child.get('type');
        if (type === 'update') {
            return <UpdatePointMarker />;
        } else if (type === 'phase') {
            return <PhasePointMarker />;
        }
    },

    className: function () {
        const { className, point, active } = this.props;
        return [
            className,
            point.get('type'),
            `point-${point.get('itemType')}`,
            active ? 'active' : ''
        ].join(' ');
    },

    render: function render() {
        const { active, point } = this.props;

        const style = {
            flexGrow: 1,
            border: active ? '1px solid yellow' : undefined
        };

        return (
            <Link className={this.className()}
                  style={style}
                  onClick={this.setActive}
                  query={{'timeline[activePointId]': point.get('id')}}>
                {this.getMarker()}
            </Link>);
    }
});
window.Point = Point;

export const PhasePointMarker = React.createClass({
    render: function render () {
        return (
            <span className="marker phase-marker">
                P
            </span>
        );
    }
});

export const UpdatePointMarker = React.createClass({
    render: function render () {
        return (
            <span className="marker update-marker">
                U
            </span>
        );
    }
});

