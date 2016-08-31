import React, { PropTypes } from 'react';
import ScrollLockedComponent from './ScrollLockedComponent';
import ActorSwitcherContainer from '../containers/ActorSwitcherContainer';
import NotificationsListContainer from '../containers/NotificationsListContainer';
import MenuItem from './MenuItem';

const ANIMATION_DURATION = 10;

const dropdownContentPropTypes = {
  children: PropTypes.oneOfType([
    PropTypes.arrayOf(PropTypes.node),
    PropTypes.node,
  ]),
  close: PropTypes.func,
  contentClassName: PropTypes.string,
  currentActor: PropTypes.object,
  renderLeft: PropTypes.bool,
  sections: PropTypes.array,
};

class DropdownContent extends ScrollLockedComponent {
  constructor(props) {
    super(props);
    this.state = {
      appearState: '',
    };
  }

  componentWillEnter(callback) {
    this.setState(
      { appearState: 'dropdown-enter' },
      () => {
        this.enterTimeout = window.setTimeout(() => {
          this.setState({ appearState: 'dropdown-enter dropdown-enter-active' }, callback);
        }, ANIMATION_DURATION);
      }
    );
  }

  componentWillLeave(callback) {
    this.setState(
      { appearState: 'dropdown-leave' },
      () => {
        this.leaveTimeout = window.setTimeout(() => {
          this.setState(
            { appearState: 'dropdown-leave dropdown-leave-active' },
            () => { this.innerLeaveTimeout = window.setTimeout(callback, 200); });
        }, 0);
      });
  }

  componentWillUnmount() {
    window.clearTimeout(this.enterTimeout);
    window.clearTimeout(this.leaveTimeout);
    window.clearTimeout(this.innerLeaveTimeout);
  }

  render() {
    const { close, sections, contentClassName, currentActor } = this.props;
    const collapseClass = this.props.renderLeft ? 'dropdown--left ' : 'dropdown-right ';

    let children;
    if (typeof this.props.children !== 'undefined') {
      children = this.props.children;
    } else {
      children = sections.map((section, i) => {
        if (typeof section.type === 'string') {
          if (section.type === 'actor_switcher') {
            return <ActorSwitcherContainer key={i} close={close} />;
          }
          return (<NotificationsListContainer key={i} done={close} {...section} />);
        }

        let title;
        if (section.title && section.items.length > 0) {
          title = <span className="dropdown-header">{section.title}</span>;
        }

        const items = section.items.map((item, childI) => {
          const childProps = item.type === 'link'
            ? Object.assign({ current_actor: currentActor }, item)
            : item;
          return <MenuItem type={item.type} key={childI} done={close} childProps={childProps} />;
        });

        return (
          <div key={i}>
            {title}
            {items}
          </div>
        );
      });
    }

    return (
      <div
        className={`dropdown-content ${collapseClass}${contentClassName} ${this.state.appearState}`}
        onWheel={this.onScrollHandler.bind(this)}
        style={null}
      >
        {children}
      </div>
    );
  }
}

DropdownContent.propTypes = dropdownContentPropTypes;

export default DropdownContent;
