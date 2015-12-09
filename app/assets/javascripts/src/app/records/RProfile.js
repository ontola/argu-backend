import { Record } from 'immutable';
import RImage from './RImage';

/**
 * Profile record class.
 * @class RProfile
 * @author Fletcher91 <thom@argu.co>
 */
const RProfile = Record({
    id: 0,
    shortname: '',
    url: '',
    displayName: '',
    profilePhoto: new RImage(),
    coverPhoto: new RImage(),
    about: '',
    actorType: 'User'
    //memberships: new RMembership() TODO: Implement RMembership
});

export default RProfile;
