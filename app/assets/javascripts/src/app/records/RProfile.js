import { Record } from 'immutable';
import RImage from './RImage';

/**
 * Profile record class.
 * @class RProfile
 * @author Fletcher91 <thom@argu.co>
 * @param {number} id
 * @param {string} shortname
 * @param {string} url
 * @param {string} displayName
 * @param {RImage} profilePhoto
 * @param {RImage} coverPhoto
 * @param {string} about
 * @param {string} actorType
 */
const RProfile = Record({
    type: 'profile',
    id: null,
    shortname: null,
    url: null,
    displayName: null,
    profilePhoto: new RImage(),
    coverPhoto: new RImage(),
    about: null,
    actorType: 'User'
    //memberships: new RMembership() TODO: Implement RMembership
});

export default RProfile;
