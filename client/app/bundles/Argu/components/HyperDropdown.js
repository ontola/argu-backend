/* globals $, FB, Actions, Bugsnag, fetch */
import React, { PropTypes } from 'react';
import ReactTransitionGroup from 'react-addons-transition-group';
import OnClickOutside from 'react-onclickoutside';
import HyperDropdownMixin from '../mixins/HyperDropdownMixin';
import { image } from '../lib/helpers';
import NotificationTrigger from './NotificationTrigger';
import CurrentUserTriggerContainer from '../containers/CurrentUserTriggerContainer';
import DropdownContent from './DropdownContent';

const propTypes = {
  current_actor: PropTypes.object,
  defaultAction: PropTypes.string,
  dropdownClass: PropTypes.string,
  fa: PropTypes.string,
  fa_after: PropTypes.string,
  image: PropTypes.object,
  title: PropTypes.string,
  trigger: PropTypes.shape({
    type: PropTypes.string,
  }),
  triggerClass: PropTypes.string,
  triggerTag: PropTypes.string,
  url: PropTypes.string,
};

const HyperDropdown = React.createClass({
  mixins: [
    HyperDropdownMixin,
    OnClickOutside,
  ],

  getDefaultProps() {
    return {
      dropdownClass: '',
      triggerTag: 'a',
    };
  },

  getInitialState() {
    return {
      currentActor: this.props.current_actor,
    };
  },

  onActorChange(data) {
    this.setState({ currentActor: data });
  },

  render() {
    const { openState, renderLeft, currentActor } = this.state;
    const dropdownClass = `dropdown ${(openState
      ? 'dropdown-active'
      : '')} ${this.props.dropdownClass}`;

    let trigger;
    if (this.props.trigger) {
      if (this.props.trigger.type === 'current_user') {
        trigger = (
          <CurrentUserTriggerContainer
            handleClick={this.handleClick}
            handleTap={this.handleTap}
          />
        );
      } else if (this.props.trigger.type === 'notifications') {
        trigger = (<NotificationTrigger
          handleClick={this.handleClick}
          handleTap={this.handleTap}
        />);
      }
    } else {
      const imageAfter = image({ fa: this.props.fa_after });
      const triggerClass = `dropdown-trigger ${this.props.triggerClass}`;
      const TriggerContainer = this.props.triggerTag;

      trigger = (
        <TriggerContainer
          href={this.props.defaultAction}
          className={triggerClass}
          onClick={this.handleClick}
          done={this.close}
          data-turbolinks="false"
        >
          {image(this.props)}
          <span className={(this.props.image || this.props.fa) ? 'icon-left' : ''}>
            {this.props.title}
          </span>
          {imageAfter}
        </TriggerContainer>
      );
    }

    const dropdownContent = (
      <DropdownContent
        renderLeft={renderLeft}
        close={this.close}
        currentActor={currentActor}
        {...this.props}
        key="required"
      />
    );

    return (
      <div
        className={dropdownClass}
        onMouseEnter={this.onMouseEnter}
        onMouseLeave={this.onMouseLeave}
        tabIndex="1"
      >
        {trigger}
        <div
          className="reference-elem"
          style={{
            visibility: 'hidden',
            overflow: 'hidden',
            pointerEvents: 'none',
            position: 'absolute',
          }}
        >
          {dropdownContent}
        </div>
        <ReactTransitionGroup transitionName="dropdown" transitionAppear component="div">
            {openState && dropdownContent}
        </ReactTransitionGroup>
      </div>
    );
  },
});

HyperDropdown.propTypes = propTypes;

export default HyperDropdown;
