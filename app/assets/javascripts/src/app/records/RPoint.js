import { Record } from 'immutable';

/**
 * Point record class.
 * @class RPoint
 * @author Fletcher91 <thom@argu.co>
 * @param {number} id
 * @param {number} timelineId
 * @param {string} itemType
 * @param {number} itemId
 */
const RPoint = Record({
    id: null,
    timelineId: null,
    itemType: null,
    itemId: null
});

export default RPoint;
