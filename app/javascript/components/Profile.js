import React from 'react';
import RProfile from './records/RProfile';

/**
 * Profile component, to display the resource creator/publisher.
 * @class Profile
 * @author Fletcher91 <thom@argu.co>
 * @param {Object} props The component properties
 */
const Profile = props => {
    const { profile, resource } = props;
    const url = profile.get('url');
    const displayName = profile.get('displayName');
    const profilePhoto = profile.get('profilePhoto');
    const createdAt = resource.get('createdAt');
    const edited = resource.get('edited');

    let editedComponent;
    if (edited === true) {
        const editedCharacter = '*';
        editedComponent = <abbr title="t('comments.edited_at', {time: l(resource.updated_at, format: :long)})">{editedCharacter}</abbr>;
    }

    return (
        <section className="profile-small"
                 itemScope
                 itemProp="creator"
                 itemType="http://schema.org/Person">
            <a href={url}>
                <img src={profilePhoto && profilePhoto.icon_url}
                     alt=""
                     className="profile-picture profile-picture--small"
                     itemProp="image" />
            </a>
            <div className="info-block">
                <a href={url}>
                    <span className="info">
                        <time dateTime={createdAt} />
                        {editedComponent}
                    </span>
                    <span className="profile-name"
                          itemProp="name">
                        {displayName}
                    </span>
                </a>
            </div>
        </section>
    );
};

Profile.propTypes = {
    profile: React.PropTypes.objectOf(RProfile),
    resource: React.PropTypes.object
};

export default Profile;
