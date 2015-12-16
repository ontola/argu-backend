import { Record } from 'immutable';

/**
 * Point record class.
 * @class RPoint
 * @author Fletcher91 <thom@argu.co>
 */
const RPoint = Record({
    id: 0,
    timelineId: 0,
    itemType: '',
    itemId: 0
});

export default RPoint;
