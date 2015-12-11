import { Record, OrderedMap, List } from 'immutable';

/**
 * TimeLine record class.
 * @class RTimeLine
 * @author Fletcher91 <thom@argu.co>
 */
const RTimeLine = Record({
    parentUrl: '',
    currentPhase: 0,
    activePointId: 0,
    phaseCount: 0,
    points: new List(),
    phases: new OrderedMap(),
    updates: new List()
});

export default RTimeLine;
