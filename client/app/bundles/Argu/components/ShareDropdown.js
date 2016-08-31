/* globals $ */
import React, { PropTypes } from 'react';
import ReactTransitionGroup from 'react-addons-transition-group';
import OnClickOutside from 'react-onclickoutside';

import HyperDropdownMixin from '../mixins/HyperDropdownMixin';
import LinkItem from './LinkItem';
import DropdownContent from './DropdownContent';
import FBShareItem from './FBShareItem';

const propTypes = {
  defaultAction: PropTypes.string,
  dropdownClass: PropTypes.string,
  shareUrls: PropTypes.object,
  title: PropTypes.string,
  url: PropTypes.string,
};

const ShareDropdown = React.createClass({
  mixins: [
    HyperDropdownMixin,
    OnClickOutside,
  ],

  getDefaultProps() {
    return {
      dropdownClass: '',
    };
  },

  getInitialState() {
    return {
      counts: {
        facebook: 0,
        linkedIn: 0,
        twitter: 0,
      },
    };
  },

  componentDidMount() {
    this.fetchFacebookCount();
    this.fetchLinkedInCount();
  },

  countInParentheses(count) {
    return count ? `(${count})` : '';
  },

  updateCount(network, amount) {
    this.setState({ counts: Object.assign(this.state.counts, { [network]: amount }) });
  },

  fetchFacebookCount() {
    $.getJSON(`https://graph.facebook.com/?id=${this.props.url}`, data => {
      this.updateCount('facebook', data.shares);
    });
  },

  fetchLinkedInCount() {
    $.getJSON(
      `https://www.linkedin.com/countserv/count/share?url=${this.props.url}&callback=?`,
      data => {
        this.updateCount('linkedIn', data.count);
      }
    );
  },

  fetchTwitterCount() {
    $.getJSON(`http://opensharecount.com/count.json?url=${this.props.url}`,
      data => {
        this.updateCount('twitter', data.count);
      }
    );
  },

  totalShares() {
    return Object.keys(this.state.counts)
      .map(k => this.state.counts[k])
      .reduce((a, b) => a + b);
  },

  render() {
    const { openState, renderLeft, counts } = this.state;
    const { title, url, shareUrls } = this.props;
    const dropdownClass = `dropdown ${(openState
        ? 'dropdown-active'
        : ''
    )} ${this.props.dropdownClass}`;

    const totalSharesCounter = (
      <div className="notification-counter share-counter">
        {this.totalShares()}
      </div>
    );

    const trigger = (
      <a
        href={this.props.defaultAction}
        className="dropdown-trigger"
        onClick={this.handleClick}
        done={this.close}
        data-turbolinks="false"
      >
        <span className="fa fa-share-alt" />
        <span className="icon-left">{title}</span>
        {this.totalShares() > 0 && totalSharesCounter}
      </a>
    );

    const dropdownContent = (
      <DropdownContent
        renderLeft={renderLeft}
        close={this.close}
        {...this.props}
        key="required"
      >
        <FBShareItem
          shareUrl={url}
          type="link"
          url={shareUrls.facebook}
          title={title}
          count={counts.facebook}
        />
        <LinkItem
          type="link"
          target="_blank"
          title={`Twitter ${this.countInParentheses(counts.twitter)}`}
          url={shareUrls.twitter}
          fa="fa-twitter"
        />
        <LinkItem
          type="link"
          target="_blank"
          title={`LinkedIn ${this.countInParentheses(counts.linkedIn)}`}
          url={shareUrls.linkedIn}
          fa="fa-linkedin"
        />
        <LinkItem
          type="link"
          target="_blank"
          title={'Google+'}
          url={shareUrls.googlePlus}
          fa="fa-google-plus"
        />
        <LinkItem
          data-action="share/whatsapp/share"
          fa="fa-whatsapp"
          title={'Whatsapp'}
          type="link"
          url={shareUrls.whatsapp} />
        <LinkItem
          fa="fa-envelope"
          title={'E-Mail'}
          type="link"
          url={shareUrls.email} />
      </DropdownContent>
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

ShareDropdown.propTypes = propTypes;

export default ShareDropdown;
