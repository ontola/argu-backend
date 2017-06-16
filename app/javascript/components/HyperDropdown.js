/* globals $, FB, Actions, Bugsnag */
import React from 'react';
import ReactTransitionGroup from 'react-addons-transition-group';
import OnClickOutside from 'react-onclickoutside';

import NotificationTrigger from './NotificationTrigger';
import { image } from './lib/helpers';
import actorStore from './stores/actor_store';
import HyperDropdownMixin from './mixins/HyperDropdownMixin';

import DropdownContent from './DropdownContent';
import CurrentUserTrigger from './CurrentUserTrigger';

export const HyperDropdown = React.createClass({
    propTypes: {
        current_actor: React.PropTypes.object,
        defaultAction: React.PropTypes.string,
        dropdownClass: React.PropTypes.string,
        fa: React.PropTypes.string,
        fa_after: React.PropTypes.string,
        image: React.PropTypes.object,
        iri: React.PropTypes.string,
        isMobile: React.PropTypes.bool,
        title: React.PropTypes.string,
        trigger: React.PropTypes.shape({
            type: React.PropTypes.string
        }),
        triggerClass: React.PropTypes.string,
        triggerTag: React.PropTypes.string,
        url: React.PropTypes.string
    },

    mixins: [
        HyperDropdownMixin,
        OnClickOutside
    ],

    getDefaultProps () {
        return {
            dropdownClass: '',
            triggerTag: 'a'
        };
    },

    getInitialState () {
        return {
            current_actor: this.props.current_actor,
            socialCounts: {
                facebook: 0,
                linkedIn: 0,
                twitter: 0
            }
        };
    },

    componentDidMount () {
        this.unsubscribe = actorStore.listen(this.onActorChange);
    },

    componentWillUnmount () {
        this.unsubscribe();
    },

    onActorChange (data) {
        this.setState({ current_actor: data });
    },

    updateCount (network, amount) {
        this.setState({ socialCounts: Object.assign(this.state.socialCounts, { [network]: amount }) });
    },

    totalShares () {
        return Object.keys(this.state.socialCounts)
            .map(k => { return this.state.socialCounts[k] })
            .reduce((a, b) => {
                return a + b;
            });
    },

    render () {
        const { openState, renderLeft, current_actor } = this.state;
        const dropdownClass = `dropdown ${(openState ? 'dropdown-active' : '')} ${this.props.dropdownClass}`;
        const totalSharesCounter = <div className="notification-counter share-counter">{this.totalShares()}</div>;

        let trigger;
        if (this.props.trigger) {
            if (this.props.trigger.type === 'current_user') {
                trigger = <CurrentUserTrigger
                 defaultAction={this.props.defaultAction}
                 handleClick={this.handleClick}
                 handleTap={this.handleTap}
                 {...this.props.trigger} />
            } else if (this.props.trigger.type === 'notifications') {
                trigger = <NotificationTrigger handleClick={this.handleClick} handleTap={this.handleTap} {...this.props} />
            }
        } else {
            const image_after = image({ fa: this.props.fa_after });
            const triggerClass = `dropdown-trigger ${this.props.triggerClass}`;
            const TriggerContainer = this.props.triggerTag;
            let title;
            if (this.props.title !== undefined) {
                title = <span className={(this.props.image || this.props.fa) ? 'icon-left' : ''}>{this.props.title}</span>;
            }
            trigger = (<TriggerContainer
              className={triggerClass}
              data-turbolinks="false"
              done={this.close}
              href={this.props.defaultAction}
              onClick={this.handleClick}
              tabIndex="0" >
                {image(this.props)}
                {title}
                {image_after}
                {this.totalShares() > 0 && totalSharesCounter}
            </TriggerContainer>);
        }

        const dropdownContent = <DropdownContent
          close={this.close}
          currentActor={current_actor}
          key='required'
          renderLeft={renderLeft}
          socialCounts={this.state.socialCounts}
          updateCount={this.updateCount}
          {...this.props} />;

        return (<div
          className={dropdownClass}
          onMouseEnter={this.onMouseEnter}
          onMouseLeave={this.onMouseLeave}
          tabIndex="1" >
            {trigger}
            <div className="reference-elem" style={{ overflow: 'hidden', 'pointerEvents': 'none', position: 'absolute', visibility: 'hidden' }}>{dropdownContent}</div>
            <ReactTransitionGroup component="div" transitionAppear={true} transitionName="dropdown">
                {openState && dropdownContent}
            </ReactTransitionGroup>
        </div>);
    }
});

export default HyperDropdown;
