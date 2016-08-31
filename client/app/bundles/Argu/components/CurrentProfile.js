import React, { PropTypes } from 'react';
import { image } from '../lib/helpers';

const propTypes = {
  display_name: PropTypes.string,
  profile_photo: PropTypes.object,
};

const CurrentProfile = props => {
  const { profile_photo: profilePhoto, display_name: displayName } = props;
  return (
    <div className="profile-small inspectlet-sensitive">
      {image({ image: profilePhoto })}
      <div className="info-block">
        <div className="info">plaatsen als:</div>
        <div className="profile-name">{displayName}</div>
      </div>
    </div>
  );
};

CurrentProfile.propTypes = propTypes;

export default CurrentProfile;
