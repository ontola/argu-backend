import { Record } from 'immutable';
import RProfile from './RProfile';
import RDateline from './RDateline';

/**
 * Update record class.
 * @class RUpdate
 * @author Fletcher91 <thom@argu.co>
 */
const RUpdate = Record({
    id: 0,
    phaseId: 0,
    title: 'UTitle',
    content: '',
    createdAt: new Date(0),
    updatedAt: new Date(0),
    dateline: new RDateline(),
    creator: new RProfile(),
    publisher: new RProfile()
});

export default RUpdate;
