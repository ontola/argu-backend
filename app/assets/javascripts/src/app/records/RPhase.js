import { Record } from 'immutable';
import RProfile from './RProfile';

/**
 * Phase record class.
 * @class RPhase
 * @author Fletcher91 <thom@argu.co>
 */
const RPhase = Record({
    id: 0,
    timelineId: 0,
    index: 0,
    title: 'PTitlte',
    content: '',
    startDate: new Date(0),
    endDate: new Date(0),
    createdAt: new Date(0),
    updatedAt: new Date(0),
    creator: new RProfile(),
    publisher: new RProfile()
});

export default RPhase;
