import React, { Component, PropTypes } from 'react';

import LinkItem from './LinkItem';
import ActorItem from './ActorItem';
import FBShareItem from './FBShareItem';

const propTypes = {
  childProps: PropTypes.object,
  done: PropTypes.func,
  type: PropTypes.oneOf(['link', 'actor', 'fb_share']).isRequired,
};

class MenuItem extends Component {
  itemType() {
    switch (this.props.type) {
      case 'actor':
        return ActorItem;
      case 'fb_share':
        return FBShareItem;
      default:
      case 'link':
        return LinkItem;
    }
  }

  render() {
    const { childProps, done } = this.props;
    const ItemType = this.itemType();

    return <ItemType done={done} {...childProps} />;
  }
}

MenuItem.propTypes = propTypes;

export default MenuItem;
