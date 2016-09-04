import React from 'react';
import { connect } from 'react-redux';

import HyperDropdown from '../components/HyperDropdown';

const ForumSelectorContainer = ({discover, memberships}) => {
  const sections = [];
  if (memberships) {
    sections.push({
      title: I18n.t('forums.mine'),
      items: memberships
    });
  }
  sections.push({
    title: I18n.t('forums.discover'),
    items: [
      ...(discover || []),
      {
        type: 'link',
        title: I18n.t('forums.show_open'),
        url: '/discover',
        fa: 'fa-compass'
      }
    ]
  });

  return (
    <HyperDropdown
      fa="fa-group"
      defaultAction="discover_forums_path"
      dropdownClass="navbar-forum-selector"
      sections={sections}
      title={I18n.t('forums.plural')}
      triggerClass="navbar-item navbar-forums"
    />
  );
};

function forumSetItems(group, state) {
  const items = state.getIn([
    'current-actors',
    'items',
    'currentactor',
    group
  ]);
  if(items) {
    return items.map(id => {
      const f = state.getIn(['forums', 'items', id.toString()]);
      return {
        type: 'link',
        title: f.title,
        url: `/${f.shortname}`,
        image: {
          url: f.get('profile-photo')
        }
      }
    })
  }
}

export default connect(
  (state, ownProps) => ({
    memberships: forumSetItems('memberships', state),
    discover: forumSetItems('discover', state),
  })
)(ForumSelectorContainer);

