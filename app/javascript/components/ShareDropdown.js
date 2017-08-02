import OnClickOutside from 'react-onclickoutside';
import React from 'react';
import ReactTransitionGroup from 'react-addons-transition-group';

import DropdownContent from './DropdownContent';
import FBShareItem from './FBShareItem';
import HyperDropdownMixin from './mixins/HyperDropdownMixin';
import LinkItem from './LinkItem';

export const ShareDropdown = React.createClass({
    propTypes: {
        defaultAction: React.PropTypes.string,
        dropdownClass: React.PropTypes.string,
        shareUrls: React.PropTypes.object,
        title: React.PropTypes.string,
        url: React.PropTypes.string
    },

    mixins: [
        HyperDropdownMixin,
        OnClickOutside
    ],

    getDefaultProps () {
        return {
            dropdownClass: ''
        };
    },

    getInitialState () {
        return {
            counts: {
                facebook: 0,
                linkedIn: 0,
                twitter: 0
            }
        };
    },

    componentDidMount () {
        this.fetchFacebookCount();
        this.fetchLinkedInCount();
    },

    countInParentheses (count) {
        return count ? `(${count})` : '';
    },

    updateCount (network, amount) {
        this.setState({ counts: Object.assign(this.state.counts, { [network]: amount }) });
    },

    fetchFacebookCount () {
        $.getJSON(`https://graph.facebook.com/?id=${this.props.url}`, data => {
            this.updateCount('facebook', data.shares);
        });
    },

    fetchLinkedInCount () {
        $.getJSON(`https://www.linkedin.com/countserv/count/share?url=${this.props.url}&callback=?`, data => {
            this.updateCount('linkedIn', data.count);
        });
    },

    fetchTwitterCount () {
        $.getJSON(`http://opensharecount.com/count.json?url=${this.props.url}`, data => {
            this.updateCount('twitter', data.count);
        });
    },

    totalShares () {
        return Object.keys(this.state.counts)
          .map(k => { return this.state.counts[k] })
          .reduce((a, b) => {
              return a + b;
          });
    },

    whatsappButton () {
        const { whatsapp } = this.props.shareUrls;
        if (whatsapp === undefined) {
            return undefined;
        }
        return (<LinkItem data-action="share/whatsapp/share"
                          fa="fa-whatsapp"
                          title={'Whatsapp'}
                          type="link"
                          url={whatsapp} />)
    },

    render () {
        const { openState, renderLeft, counts } = this.state;
        const { title, url, shareUrls } = this.props;
        const dropdownClass = `dropdown ${(openState ? 'dropdown-active' : '')} ${this.props.dropdownClass}`;

        const totalSharesCounter = <div className="notification-counter share-counter">{this.totalShares()}</div>;

        const trigger = (<a className="dropdown-trigger"
                            data-turbolinks="false"
                            done={this.close}
                            href={this.props.defaultAction}
                            onClick={this.handleClick}>
            <span className="fa fa-share-alt" />
            <span className="icon-left">{title}</span>
            {this.totalShares() > 0 && totalSharesCounter}
        </a>);

        const dropdownContent = <DropdownContent close={this.close}
                                                 key='required'
                                                 renderLeft={renderLeft}
                                                 {...this.props}>
            <FBShareItem
              count={counts.facebook}
              shareUrl={url}
              title={title}
              type="link"
              url={shareUrls.facebook} />
            <LinkItem
              fa="fa-twitter"
              target="_blank"
              title={`Twitter ${this.countInParentheses(counts.twitter)}`}
              type="link"
              url={shareUrls.twitter} />
            <LinkItem
              fa="fa-linkedin"
              target="_blank"
              title={`LinkedIn ${this.countInParentheses(counts.linkedIn)}`}
              type="link"
              url={shareUrls.linkedIn} />
            <LinkItem
              fa="fa-google-plus"
              target="_blank"
              title={'Google+'}
              type="link"
              url={shareUrls.googlePlus} />
            {this.whatsappButton()}
            <LinkItem
              fa="fa-envelope"
              title={'E-Mail'}
              type="link"
              url={shareUrls.email} />
        </DropdownContent>;
        return (<div
          className={dropdownClass}
          onMouseEnter={this.onMouseEnter}
          onMouseLeave={this.onMouseLeave}
          tabIndex="-1" >
            {trigger}
            <div className="reference-elem" style={{ overflow: 'hidden', 'pointerEvents': 'none', position: 'absolute', visibility: 'hidden' }}>{dropdownContent}</div>
            <ReactTransitionGroup component="div" transitionAppear={true} transitionName="dropdown" >
                {openState && dropdownContent}
            </ReactTransitionGroup>
        </div>);
    }
});

export default ShareDropdown;
