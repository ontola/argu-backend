import { Record } from 'immutable';

/**
 * Image record class.
 * @class RImage
 * @author Fletcher91 <thom@argu.co>
 */
const RImage = Record({
    type: 'image',
    id: 0,
    url: '',
    icon_url: ''
});

export default RImage;
