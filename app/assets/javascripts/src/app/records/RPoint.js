import { Record } from 'immutable';

/**
 * Point record class.
 * @class RPoint
 * @author Fletcher91 <thom@argu.co>
 * @param {number} id
 * @param {number} timelineId
 * @param {number} sortDate Date at which this point should be shown
 * @param {string} itemType
 * @param {number} itemId
 */
const RPoint = Record({
    type: 'point',
    id: null,
    timelineId: null,
    sortDate: new Date(0),
    itemType: null,
    itemId: null
});

export default RPoint;
