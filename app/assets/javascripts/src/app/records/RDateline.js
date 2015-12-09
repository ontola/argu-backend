import { Record } from 'immutable';

/**
 * Dateline record class.
 * @class RDateline
 * @author Fletcher91 <thom@argu.co>
 */
const RDateline = Record({
    date: new Date(0),
    location: ''
});

export default RDateline;
