/* globals $, FB, Actions */
import React from 'react';
import ReactDOM from 'react-dom';
import ReactTransitionGroup from 'react-addons-transition-group';
import OnClickOutside from 'react-onclickoutside';
import { image } from '../lib/helpers';
import { NotificationTrigger } from './Notifications';
import { safeCredentials, statusSuccess, json } from '../lib/helpers';
import actorStore from '../stores/actor_store';
import HyperDropdownMixin from '../mixins/HyperDropdownMixin';


export const HyperDropdown = React.createClass({
    mixins: [
        HyperDropdownMixin,
        OnClickOutside
    ],

    getInitialState: function () {
        return {
            current_actor: this.props.current_actor
        };
    },

    componentDidMount: function () {
        this.unsubscribe = actorStore.listen(this.onActorChange);
    },

    componentWillUnmount: function () {
        this.unsubscribe();
    },

    onActorChange: function (data) {
        this.setState({current_actor: data});
    },

    render: function () {
        const { openState, renderLeft, current_actor } = this.state;
        const dropdownClass = `dropdown ${(openState ? 'dropdown-active' : '')} ${this.props.dropdownClass || ''}`;

        var trigger;
        if (this.props.trigger) {
            if (this.props.trigger.type === 'current_user') {
                trigger = <CurrentUserTrigger handleClick={this.handleClick} handleTap={this.handleTap} {...this.props.trigger} />
            } else if (this.props.trigger.type === 'notifications') {
                trigger = <NotificationTrigger handleClick={this.handleClick} handleTap={this.handleTap} {...this.props} />
            }
        } else {
            const image_after = image({fa: this.props.fa_after});
            const triggerClass = 'dropdown-trigger ' + this.props.triggerClass;
            const TriggerContainer = this.props.triggerTag || 'a';
            trigger = (<TriggerContainer href={this.props.defaultAction} className={triggerClass} onClick={this.handleClick} done={this.close} data-turbolinks="false">
                          {image(this.props)}
                          <span className={(this.props.image || this.props.fa) ? 'icon-left' : ''}>{this.props.title}</span>
                          {image_after}
                       </TriggerContainer>);
        }

        let dropdownContent = <DropdownContent renderLeft={renderLeft}
                                               close={this.close}
                                               currentActor={current_actor}
                                               {...this.props}
                                               key='required' />;

        return (<div tabIndex="1"
                    className={dropdownClass}
                    onMouseEnter={this.onMouseEnter}
                    onMouseLeave={this.onMouseLeave} >
            {trigger}
            <div className="reference-elem" style={{visibility: 'hidden', overflow: 'hidden', 'pointerEvents': 'none', position: 'absolute'}}>{dropdownContent}</div>
            <ReactTransitionGroup transitionName="dropdown" transitionAppear={true} component="div">
                {openState && dropdownContent}
            </ReactTransitionGroup>
        </div>);
    }
});
window.HyperDropdown = HyperDropdown;

export const ShareDropdown = React.createClass({
    mixins: [
        HyperDropdownMixin,
        OnClickOutside
    ],

    getInitialState: function () {
        return {
            counts: {
                facebook: 0,
                linkedIn: 0,
                twitter: 0
            }
        };
    },

    componentDidMount: function () {
        this.fetchFacebookCount();
        this.fetchLinkedInCount();
    },

    countInParentheses: function (count) {
        return count ? `(${count})` : '';
    },

    updateCount: function (network, amount) {
        this.setState({counts: Object.assign(this.state.counts, {[network]: amount})});
    },

    fetchFacebookCount: function () {
        $.getJSON(`https://graph.facebook.com/?id=${this.props.url}`, data => {
            this.updateCount('facebook', data.shares);
        });
    },

    fetchLinkedInCount: function () {
        $.getJSON(`https://www.linkedin.com/countserv/count/share?url=${this.props.url}&callback=?`, data => {
            this.updateCount('linkedIn', data.count);
        });
    },

    fetchTwitterCount: function () {
        $.getJSON(`http://opensharecount.com/count.json?url=${this.props.url}`, data => {
            this.updateCount('twitter', data.count);
        });
    },

    totalShares: function () {
        return Object.keys(this.state.counts)
                .map(k => { return this.state.counts[k] })
                .reduce((a, b) => {
                    return a + b;
                });
    },

    render: function () {
        const { openState, renderLeft, counts } = this.state;
        const { title, url, shareUrls } = this.props;
        const dropdownClass = `dropdown ${(openState ? 'dropdown-active' : '')} ${this.props.dropdownClass || ''}`;

        let totalSharesCounter = <div className="notification-counter share-counter">{this.totalShares()}</div>;

        const trigger = (<a href={this.props.defaultAction}
                            className="dropdown-trigger"
                            onClick={this.handleClick}
                            done={this.close}
                            data-turbolinks="false">
            <span className="fa fa-share-alt"></span>
            <span className="icon-left">{title}</span>
            {this.totalShares() > 0 && totalSharesCounter}
        </a>);

        let dropdownContent = <DropdownContent renderLeft={renderLeft}
                                               close={this.close}
                                               {...this.props}
                                               key='required' >
            <FBShareItem
                    shareUrl={url}
                    url={shareUrls.facebook}
                    title={title}
                    count={counts.facebook} />
            <LinkItem
                    type="link"
                    title={`Twitter ${this.countInParentheses(counts.twitter)}`}
                    url={shareUrls.twitter}
                    fa="fa-twitter" />
            <LinkItem
                    type="link"
                    title={`LinkedIn ${this.countInParentheses(counts.linkedIn)}`}
                    url={shareUrls.linkedIn}
                    fa="fa-linkedin" />
            <LinkItem
                    type="link"
                    title={`Google+`}
                    url={shareUrls.googlePlus}
                    fa="fa-google-plus" />
            </DropdownContent>;

        return (<div tabIndex="1"
                    className={dropdownClass}
                    onMouseEnter={this.onMouseEnter}
                    onMouseLeave={this.onMouseLeave} >
            {trigger}
            <div className="reference-elem" style={{visibility: 'hidden', overflow: 'hidden', 'pointerEvents': 'none', position: 'absolute'}}>{dropdownContent}</div>
            <ReactTransitionGroup transitionName="dropdown" transitionAppear={true} component="div">
                {openState && dropdownContent}
            </ReactTransitionGroup>
        </div>);
    }
});
window.ShareDropdown = ShareDropdown;

export const DropdownContent = React.createClass({
    getInitialState: function () {
        return {
            appearState: ''
        };
    },

    componentWillEnter: function (callback) {
        this.setState(
            {appearState: 'dropdown-enter'},
            () => {
                window.setTimeout(() => {
                    this.setState({appearState: 'dropdown-enter dropdown-enter-active'}, callback);
                }, 10);
            }
        );
    },

    componentWillLeave: function (callback) {
        this.setState(
            {appearState: 'dropdown-leave'},
            () => {
                window.setTimeout(() => {
                    this.setState(
                        {appearState: 'dropdown-leave dropdown-leave-active'},
                        () => { window.setTimeout(callback, 200) });
                }, 0);
            });
    },

    render: function() {
        const { close, sections, contentClassName, currentActor } = this.props;
        const collapseClass = this.props.renderLeft ? 'dropdown--left ' : 'dropdown-right ';

        let children;
        if (typeof this.props.children !== 'undefined') {
            children = this.props.children;
        } else {
            children = sections.map((section, i) => {
                if (typeof section.type === 'string') {
                    return (<Notifications key={i} done={close} {...section} />);
                } else {
                    let title;
                    if (section.title && section.items.length > 0) {
                        title = <span className="dropdown-header">{section.title}</span>
                    }

                    const items = section.items.map(function(item) {
                        if (item.type === 'link') {
                            return <LinkItem key={item.title} done={close} current_actor={currentActor} {...item} />;
                        } else if (item.type === 'actor') {
                            return <ActorItem key={item.title} done={close} {...item} />;
                        } else if (item.type === 'fb_share') {
                            return <FBShareItem key={item.title} done={close} {...item} />;
                        }
                    });

                    return (
                        <div key={i}>
                            {title}
                            {items}
                        </div>);
                }
            });
        }

        return (<div className={'dropdown-content ' + collapseClass + contentClassName + ' ' + this.state.appearState} style={null}>
                {children}
            </div>);
    }
});
window.DropdownContent = DropdownContent;

export const LinkItem = React.createClass({
    getInitialState: function () {
        return {};
    },

    handleMouseDown: function () {
        // Fixes an issue where firefox bubbles events instead of capturing them
        // See: https://github.com/facebook/react/issues/2011
        let dataMethod = ReactDOM.findDOMNode(this).getAttribute('data-method');
        if (dataMethod !== 'post' && dataMethod !== 'put' && dataMethod !== 'patch' && dataMethod !== 'delete') {
            ReactDOM.findDOMNode(this).getElementsByTagName('a')[0].click();
            this.props.done();
        }
    },

    render: function () {
        var divider;
        if (this.props.divider && this.props.divider === 'top') {
            divider = <div className="dropdown-divider"></div>;
        }
        var method, confirm, remote, turbolinks, sortValue, filterValue, className, displaySetting;
        if (this.props.data) {
            method = this.props.data.method;
            confirm = this.props.data.confirm;
            remote = this.props.data.remote;
            turbolinks = this.props.data['turbolinks'];
            sortValue = this.props.data['sort-value'];
            filterValue = this.props.data['filter-value'];
            displaySetting = this.props.data['display-setting'];
        }
        className = this.props.className;

        return (<div className={this.props.type}>
            {divider}
            <a href={this.props.url} data-remote={remote} data-method={method} data-confirm={confirm} onMouseDownCapture={this.handleMouseDown} data-turbolinks={turbolinks} data-sort-value={sortValue} data-filter-value={filterValue} data-display-setting={displaySetting} className={className}>
                {image(this.props)}
                <span className={(this.props.image || this.props.fa) ? 'icon-left' : ''}>{this.props.title}</span>
            </a>
        </div>);
    }
});
window.LinkItem = LinkItem;

export const FBShareItem = React.createClass({
    handleClick: function (e) {
        if (typeof FB !== 'undefined') {
            e.preventDefault();
            FB.ui({
                method: 'share',
                href: this.props.shareUrl,
                caption: this.props.title
            }, () => {
                this.props.done();
            });
        }
    },

    countInParentheses: function () {
        return this.props.count > 0 ? `(${this.props.count})` : '';
    },

    render: function () {
        return (<div className={this.props.type}>
            <a href={this.props.url} data-turbolinks="false" onClick={this.handleClick}>
                {image({fa: 'fa-facebook'})}
                <span className="icon-left">Facebook {this.countInParentheses()}</span>
            </a>
        </div>);
    }
});
window.FBShareItem = FBShareItem;

export const ActorItem = React.createClass({
    getInitialState: function () {
        return {};
    },

    handleClick: function (e) {
        e.preventDefault();
    },
    
    switchActor: function () {
        this.props.done();
        fetch(this.props.url, safeCredentials({
            method: 'PUT'
        })).then(statusSuccess)
           .then(json)
           .then(function (data) {
               Actions.actorUpdate(data);
               if (window.confirm('Sommige mogelijkheden zijn niet zichtbaar totdat de pagina opnieuw geladen is, nu opnieuw laden?')) {
                   location.reload();
               }
           }).catch((e) => {
               throw e;
           });
    },
    
    handleTap: function () {
        this.switchActor();
    },

    handleMouseDown: function (e) {
        e.preventDefault();
        this.switchActor();
    },

    render: function () {
        var divider;
        if (this.props.divider && this.props.divider === 'top') {
            divider = <div className="dropdown-divider"></div>;
        }
        var turbolinks;
        if (this.props.data) {
            turbolinks = this.props.data['turbolinks'];
        }

        return (<div className={'link ' + this.props.type}>
            {divider}
            <a href='#' onMouseDownCapture={this.handleMouseDown} rel="nofollow" onTouchEnd={this.handleTap} onClickCapture={this.handleClick} data-turbolinks={turbolinks}>
                {image(this.props)}
                <span className={(this.props.image || this.props.fa) ? 'icon-left' : ''}>{this.props.title}</span>
            </a>
        </div>);
    }
});
window.ActorItem = ActorItem;

export const CurrentUserTrigger = React.createClass({
    getInitialState: function () {
        return {
            display_name: this.props.title,
            profile_photo: this.props.profile_photo
        };
    },

    onActorChange: function (data) {
        this.setState(data);
    },

    componentDidMount: function () {
        this.unsubscribe = actorStore.listen(this.onActorChange);
    },

    componentWillUnmount: function () {
        this.unsubscribe();
    },

    render: function () {
        var triggerClass = 'dropdown-trigger ' + this.props.triggerClass;
        var TriggerContainer = this.props.triggerTag || 'div';

        return (<TriggerContainer className={triggerClass} onClick={this.props.handleClick} onTouchEnd={this.props.handleTap} >
            {image({image: {url: this.state.profile_photo.url, title: this.state.profile_photo.title, className: 'profile-picture--navbar'}})}
            <span className="icon-left">{this.state.display_name}</span>
        </TriggerContainer>);
    }
});
window.CurrentUserTrigger = CurrentUserTrigger;
