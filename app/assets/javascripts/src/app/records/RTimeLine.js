import { Record, OrderedMap, List } from 'immutable';

/**
 * Timeline record class.
 * @class RTimeline
 * @author Fletcher91 <thom@argu.co>
 */
const PTimeline = Record({
    id: 0,
    parentUrl: '',
    currentPhase: 0,
    activePointId: 0,
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
