import React, { PropTypes } from 'react';
import { image } from '../lib/helpers';

const propTypes = {
  handleClick: PropTypes.func,
  handleTap: PropTypes.func,
  profilePhoto: PropTypes.object,
  title: PropTypes.string,
  triggerClass: PropTypes.string,
};

const CurrentUserTrigger = (
  {
    handleClick,
    handleTap,
    profilePhoto,
    title,
  }
) => (
  <div
    className="dropdown-trigger navbar-item navbar-profile"
    onClick={handleClick}
    onTouchEnd={handleTap}
  >
    {image({ image: {
      url: profilePhoto.url,
      title: profilePhoto.title, className: 'profile-picture--navbar' },
    })}
    <span className="icon-left">{title}</span>
  </div>
);

CurrentUserTrigger.propTypes = propTypes;

export default CurrentUserTrigger;
