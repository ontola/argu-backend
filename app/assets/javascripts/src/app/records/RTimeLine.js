import { Record, OrderedMap, List } from 'immutable';

/**
 * TimeLine record class.
 * @class RTimeLine
 * @author Fletcher91 <thom@argu.co>
 */
const RTimeLine = Record({
    parentUrl: '',
    currentPhase: 0,
    activePoint: 0,
    phaseCount: 0,
    phases: new OrderedMap(),
    updates: new List()
});

export default RTimeLine;
