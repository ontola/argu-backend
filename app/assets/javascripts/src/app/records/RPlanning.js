import { Record } from 'immutable';
import RDateline from './RDateline';

/**
 * Planning record class.
 * @class RPlanning
 * @author Fletcher91 <thom@argu.co>
 */
const RPlanning = Record({
    type: 'planning',
    id: 0,
    title: '',
    content: '',
    createdAt: new Date(0),
    updatedAt: new Date(0),
    dateline: new RDateline(),
    creatorId: 0
});

export default RPlanning;
