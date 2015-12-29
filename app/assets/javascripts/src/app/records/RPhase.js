import { Record } from 'immutable';
import RProfile from './RProfile';

/**
 * Phase record class.
 * @class RPhase
 * @author Fletcher91 <thom@argu.co>
 * @param {number} id
 * @param {number} timelineId
 * @param {number} index
 * @param {string} title
 * @param {string} content
 * @param {Date} startDate
 * @param {Date} endDate
 * @param {Date} createdAt
 * @param {Date} updatedAt
 * @param {RProfile} creator
 * @param {RProfile} publisher
 */
const RPhase = Record({
    id: null,
    timelineId: null,
    index: null,
    title: '',
    content: '',
    startDate: new Date(0),
    endDate: new Date(0),
    createdAt: new Date(0),
    updatedAt: new Date(0),
    creator: new RProfile(),
    publisher: new RProfile()
});

export default RPhase;
