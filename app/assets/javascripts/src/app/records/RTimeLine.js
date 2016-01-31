import { Record, OrderedMap, List } from 'immutable';

/**
 * Timeline record class.
 * @class RTimeline
 * @author Fletcher91 <thom@argu.co>
 * @param {number} id
 * @param {string} parentUrl
 * @param {number} currentPhase
 * @param {number} activePointId
 * @param {!number} phaseCount
 * @param {!List} points
 * @param {!OrderedMap} phases
 * @param {!List} updates
 */
const PTimeline = Record({
    type: 'timeline',
    id: null,
    parentUrl: null,
    currentPhase: null,
    activePointId: null,
    phaseCount: 0,
    points: new List(),
    phases: new OrderedMap(),
    updates: new List()
});

class RTimeline extends PTimeline {
    getNextPoint () {

    }

    getPreviousPoint () {

    }
}

export default RTimeline;
