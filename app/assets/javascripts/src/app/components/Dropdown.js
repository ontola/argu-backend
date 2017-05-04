/* globals $, FB, Actions, Bugsnag */
import React from 'react';
import ReactDOM from 'react-dom';
import ReactTransitionGroup from 'react-addons-transition-group';
import OnClickOutside from 'react-onclickoutside';

import { Notifications, NotificationTrigger } from './Notifications';
import { image, safeCredentials, statusSuccess, json } from '../lib/helpers';
import actorStore from '../stores/actor_store';
import HyperDropdownMixin from '../mixins/HyperDropdownMixin';

export const HyperDropdown = React.createClass({
    propTypes: {
        current_actor: React.PropTypes.object,
        defaultAction: React.PropTypes.string,
        dropdownClass: React.PropTypes.string,
        fa: React.PropTypes.string,
        fa_after: React.PropTypes.string,
        image: React.PropTypes.object,
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
            current_actor: this.props.current_actor
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

    render () {
        const { openState, renderLeft, current_actor } = this.state;
        const dropdownClass = `dropdown ${(openState ? 'dropdown-active' : '')} ${this.props.dropdownClass}`;

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
                       </TriggerContainer>);
        }

        const dropdownContent = <DropdownContent 
                                 close={this.close}
                                 currentActor={current_actor}
                                 key='required' 
                                 renderLeft={renderLeft}
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
window.HyperDropdown = HyperDropdown;

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
window.ShareDropdown = ShareDropdown;

const ANIMATION_DURATION = 10;

export const DropdownContent = React.createClass({
    propTypes: {
        children: React.PropTypes.oneOfType([
            React.PropTypes.arrayOf(React.PropTypes.node),
            React.PropTypes.node
        ]),
        close: React.PropTypes.func,
        contentClassName: React.PropTypes.string,
        currentActor: React.PropTypes.object,
        renderLeft: React.PropTypes.bool,
        sections: React.PropTypes.array
    },

    getInitialState () {
        return {
            appearState: ''
        };
    },

    componentWillUnmount () {
        window.clearTimeout(this.enterTimeout);
        window.clearTimeout(this.leaveTimeout);
        window.clearTimeout(this.innerLeaveTimeout);
    },

    componentWillEnter (callback) {
        this.setState(
            { appearState: 'dropdown-enter' },
            () => {
                this.enterTimeout = window.setTimeout(() => {
                    this.setState({ appearState: 'dropdown-enter dropdown-enter-active' }, callback);
                }, ANIMATION_DURATION);
            }
        );
    },

    componentWillLeave (callback) {
        this.setState(
            { appearState: 'dropdown-leave' },
            () => {
                this.leaveTimeout = window.setTimeout(() => {
                    this.setState(
                        { appearState: 'dropdown-leave dropdown-leave-active' },
                        () => { this.innerLeaveTimeout = window.setTimeout(callback, 200) });
                }, 0);
            });
    },

    render () {
        const { close, contentClassName, currentActor, sections } = this.props;
        const collapseClass = this.props.renderLeft ? 'dropdown--left ' : 'dropdown-right ';

        let children;
        if (typeof this.props.children !== 'undefined') {
            children = this.props.children;
        } else {
            children = sections.map((section, i) => {
                if (typeof section.type === 'string') {
                    return (<Notifications done={close} key={i} {...section} />);
                } else {
                    let title;
                    if (section.title && section.items.length > 0) {
                        title = <span className="dropdown-header">{section.title}</span>
                    }

                    const items = section.items.map((item, childI) => {
                        if (item.type === 'link') {
                            return <LinkItem current_actor={currentActor} done={close} key={childI} {...item} />;
                        } else if (item.type === 'actor') {
                            return <ActorItem done={close} key={childI} {...item} />;
                        } else if (item.type === 'fb_share') {
                            return <FBShareItem done={close} key={childI} {...item} />;
                        }
                        return <div key={childI} />
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
    propTypes: {
        className: React.PropTypes.string,
        data: React.PropTypes.shape({
            method: React.PropTypes.string,
            confirm: React.PropTypes.string,
            remote: React.PropTypes.string,
            'turbolinks': React.PropTypes.string,
            'sort-value': React.PropTypes.string,
            'filter-value': React.PropTypes.string,
            'display-setting': React.PropTypes.string
        }),
        divider: React.PropTypes.func,
        done: React.PropTypes.func,
        fa: React.PropTypes.string,
        image: React.PropTypes.object,
        target: React.PropTypes.string,
        title: React.PropTypes.string,
        type: React.PropTypes.string,
        url: React.PropTypes.string
    },

    getInitialState () {
        return {};
    },

    handleMouseDown () {
        // Fixes an issue where firefox bubbles events instead of capturing them
        // See: https://github.com/facebook/react/issues/2011
        const dataMethod = ReactDOM.findDOMNode(this).getAttribute('data-method');
        if (dataMethod !== 'post' && dataMethod !== 'put' && dataMethod !== 'patch' && dataMethod !== 'delete') {
            ReactDOM.findDOMNode(this).getElementsByTagName('a')[0].click();
            this.props.done();
        }
    },

    render () {
        let divider, method, confirm, remote, turbolinks, sortValue, filterValue, displaySetting;
        if (this.props.divider && this.props.divider === 'top') {
            divider = <div className="dropdown-divider"></div>;
        }
        const { target, className } = this.props;
        if (this.props.data) {
            method = this.props.data.method;
            confirm = this.props.data.confirm;
            remote = this.props.data.remote;
            turbolinks = this.props.data['turbolinks'];
            sortValue = this.props.data['sort-value'];
            filterValue = this.props.data['filter-value'];
            displaySetting = this.props.data['display-setting'];
        }

        return (<div className={this.props.type}>
            {divider}
            <a className={className}
               data-confirm={confirm}
               data-display-setting={displaySetting}
               data-filter-value={filterValue}
               data-method={method}
               data-remote={remote}
               data-sort-value={sortValue}
               data-turbolinks={turbolinks}
               href={this.props.url}
               onMouseDownCapture={this.handleMouseDown}
               target={target} >
                {image(this.props)}
                <span className={(this.props.image || this.props.fa) ? 'icon-left' : ''}>{this.props.title}</span>
            </a>
        </div>);
    }
});
window.LinkItem = LinkItem;

export const FBShareItem = React.createClass({
    propTypes: {
        count: React.PropTypes.number,
        done: React.PropTypes.func,
        shareUrl: React.PropTypes.string,
        title: React.PropTypes.string,
        type: React.PropTypes.string,
        url: React.PropTypes.string
    },

    handleClick (e) {
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

    countInParentheses () {
        return this.props.count > 0 ? `(${this.props.count})` : '';
    },

    render () {
        return (<div className={`link ${this.props.type}`}>
            <a data-turbolinks="false" href={this.props.url} onClick={this.handleClick} target="_blank">
                {image({ fa: 'fa-facebook' })}
                <span className="icon-left">Facebook {this.countInParentheses()}</span>
            </a>
        </div>);
    }
});
window.FBShareItem = FBShareItem;

export const ActorItem = React.createClass({
    propTypes: {
        data: React.PropTypes.shape({
            'turbolinks': React.PropTypes.string
        }),
        divider: React.PropTypes.string,
        done: React.PropTypes.func,
        fa: React.PropTypes.string,
        image: React.PropTypes.object,
        title: React.PropTypes.string,
        type: React.PropTypes.string,
        url: React.PropTypes.string
    },

    getInitialState () {
        return {};
    },

    handleClick (e) {
        e.preventDefault();
    },

    switchActor () {
        this.props.done();
        fetch(this.props.url, safeCredentials({
            method: 'PUT'
        })).then(statusSuccess)
           .then(json)
           .then(data => {
               Actions.actorUpdate(data);
               if (window.confirm('Sommige mogelijkheden zijn niet zichtbaar totdat de pagina opnieuw geladen is, nu opnieuw laden?')) {
                   location.reload();
               }
           }).catch(e => {
               Bugsnag.notifyException(e);
               throw e;
           });
    },

    handleTap () {
        this.switchActor();
    },

    handleMouseDown (e) {
        e.preventDefault();
        this.switchActor();
    },

    render () {
        let divider, turbolinks;
        if (this.props.divider && this.props.divider === 'top') {
            divider = <div className="dropdown-divider"></div>;
        }
        if (this.props.data) {
            turbolinks = this.props.data['turbolinks'];
        }

        return (<div className={`link ${this.props.type}`}>
            {divider}
            <a data-turbolinks={turbolinks}
               href='#'
               onClickCapture={this.handleClick}
               onMouseDownCapture={this.handleMouseDown}
               onTouchEnd={this.handleTap}
               rel="nofollow" >
                {image(this.props)}
                <span className={(this.props.image || this.props.fa) ? 'icon-left' : ''}>{this.props.title}</span>
            </a>
        </div>);
    }
});
window.ActorItem = ActorItem;

export const CurrentUserTrigger = React.createClass({
    propTypes: {
        defaultAction: React.PropTypes.string,
        handleClick: React.PropTypes.func,
        handleTap: React.PropTypes.func,
        profile_photo: React.PropTypes.object,
        title: React.PropTypes.string,
        triggerClass: React.PropTypes.string,
        triggerTag: React.PropTypes.string
    },

    getDefaultProps () {
        return {
            triggerTag: 'a'
        };
    },


    getInitialState () {
        return {
            display_name: this.props.title,
            profile_photo: this.props.profile_photo
        };
    },

    componentDidMount () {
        this.unsubscribe = actorStore.listen(this.onActorChange);
    },

    componentWillUnmount () {
        this.unsubscribe();
    },

    onActorChange (data) {
        this.setState(data);
    },

    render () {
        const triggerClass = 'dropdown-trigger ' + this.props.triggerClass;
        const TriggerContainer = this.props.triggerTag;

        return (<TriggerContainer className={triggerClass}
                                  href={this.props.defaultAction}
                                  onClick={this.props.handleClick}
                                  onTouchEnd={this.props.handleTap} >
            {image({ image: {
                url: this.state.profile_photo.url,
                title: this.state.profile_photo.title, className: 'profile-picture--navbar' }
            })}
            <span className="icon-left">{this.state.display_name}</span>
        </TriggerContainer>);
    }
});
window.CurrentUserTrigger = CurrentUserTrigger;
