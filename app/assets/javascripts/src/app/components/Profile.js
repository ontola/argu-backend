import React from 'react';
import RProfile from '../records/RProfile';

/**
 * Profile component, to display the resource creator/publisher.
 * @class Profile
 * @author Fletcher91 <thom@argu.co>
 */
const Profile = React.createClass({
    propTypes: {
        profile: React.PropTypes.object,
        resource: React.PropTypes.object
    },

    render: function render() {
        const { url, displayName, profilePhoto } = this.props.profile;
        const { createdAt, edited } = this.props.resource;

        let editedComponent;
        if (edited === true) {
            editedComponent = <abbr title="t('comments.edited_at', {time: l(resource.updated_at, format: :long)})">*</abbr>;
        }

        return (
            <section className="profile-small" itemScope itemProp="creator" itemType="http://schema.org/Person">
                <a href={url}>
                    <img src={profilePhoto && profilePhoto.icon_url}
                         alt=""
                         className="profile-picture profile-picture--small"
                         itemProp="image" />
                </a>
                <div className="info-block">
                    <a href={url}>
                        <span className="info">
                            <time dateTime={createdAt}></time>
                            {editedComponent}
                        </span>
                        <span className="profile-name" itemProp="name">{displayName}</span>
                    </a>
                </div>
            </section>
        );
    }
});

export default Profile;
