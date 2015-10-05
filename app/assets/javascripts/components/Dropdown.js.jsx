import React from 'react/react-with-addons';
import { image } from '../lib/helpers';
import { NotificationTrigger } from './Notifications';
import { safeCredentials } from '../lib/helpers;

function isTouchDevice() {
    return (('ontouchstart' in window)
    || (navigator.MaxTouchPoints > 0)
    || (navigator.msMaxTouchPoints > 0));
    //navigator.msMaxTouchPoints for microsoft IE backwards compatibility
}

export var HyperDropdownMixin = {

    getInitialState: function () {
        this.listeningToClick = true;
        this.openedByClick = false;
        return {
            openState: false,
            renderLeft: false,
            dropdownElement: {}
        };
    },

    calculateRenderLeft: function () {
        this.referenceDropdownElement().style.left = '0';
        this.referenceDropdownElement().style.right = 'auto';
        var elemRect = this.referenceDropdownElement().getBoundingClientRect();
        var shouldRenderLeft = (elemRect.width + elemRect.left) > window.innerWidth;
        this.setState({renderLeft: shouldRenderLeft});
    },

    close: function () {
        this.listeningToClick = true;
        this.openedByClick = false;
        this.setState({openState: false});
    },

    componentDidMount: function () {
        this.setState({
            referenceDropdownElement: this.getDOMNode().getElementsByClassName('dropdown-content')[0],
            dropdownElement: this.getDOMNode().getElementsByClassName('dropdown-content')[1]});
        window.addEventListener('resize', this.handleResize);
        this.calculateRenderLeft();
    },

    componentWillUnmount: function () {
        window.removeEventListener('resize', this.handleResize);
    },

    handleClick: function (e) {
        e.preventDefault();
        e.stopPropagation();
        if (this.listeningToClick) {
            if (this.state.openState) {
                this.close();
            } else {
                this.open();
            }
        } else {
            this.openedByClick = true;
            this.listeningToClick = true;
        }
    },

    handleClickOutside: function () {
        if (this.state.openState == true) {
            this.close();
        }
    },

    mouseEnterTimeoutCallback: function () {
        this.listeningToClick = true;
    },

    onMouseEnter: function () {
        if (!isTouchDevice() && !this.state.openState) {
            this.listeningToClick = false;
            // Start timer to prevent a quick close after clicking on the trigger
            this.mouseEnterOpenedTimeout = window.setTimeout(this.mouseEnterTimeoutCallback, 1000);
            this.open();
        }
    },

    onMouseLeave: function () {
        if (!isTouchDevice() && this.state.openState) {
            if (!this.openedByClick) {
                this.close();
                // Remove / reset timer
                window.clearTimeout(this.mouseEnterOpenedTimeout);
            }
        }
    },

    handleResize: function () {
        this.calculateRenderLeft();
    },

    open: function () {
        window.clearTimeout(this.timerItem);
        this.setState({openState: true});
    },

    // Used to calculate the width of a dropdown content menu
    referenceDropdownElement: function () {
        let refDropdown;
        if (typeof(this.state.referenceDropdownElement) !== "undefined") {
            refDropdown = this.state.referenceDropdownElement;
        } else {
            refDropdown = this.getDOMNode().getElementsByClassName('dropdown-content')[0];
        }
        return refDropdown;
    }
};
window.HyperDropdown = HyperDropdown;

export var HyperDropdown = React.createClass({
    mixins: [
        HyperDropdownMixin,
        (typeof(OnClickOutside) !== "undefined" ? OnClickOutside : undefined)
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
            if (this.props.trigger.type == 'current_user') {
                trigger = <CurrentUserTrigger handleClick={this.handleClick} handleTap={this.handleTap} {...this.props.trigger} />
            } else if (this.props.trigger.type == 'notifications') {
                trigger = <NotificationTrigger handleClick={this.handleClick} handleTap={this.handleTap} {...this.props} />
            }
        } else {
            const image_after  = image({fa: this.props.fa_after});
            const triggerClass = "dropdown-trigger " + this.props.triggerClass;
            const TriggerContainer = this.props.triggerTag || 'a';
            trigger = (<TriggerContainer href={this.props.defaultAction} className={triggerClass} onClick={this.handleClick} done={this.close} data-skip-pjax="true">
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

        const ReactTransitionGroup = React.addons.TransitionGroup;
        return (<li tabIndex="1"
                    className={dropdownClass}
                    onMouseEnter={this.onMouseEnter}
                    onMouseLeave={this.onMouseLeave} >
            {trigger}
            <div className="reference-elem" style={{visibility: 'hidden', overflow: 'hidden', 'pointer-events': 'none', position: 'absolute'}}>{dropdownContent}</div>
            <ReactTransitionGroup transitionName="dropdown" transitionAppear={true} component="div">
                {openState && dropdownContent}
            </ReactTransitionGroup>
        </li>);
    }
});

export var ShareDropdown = React.createClass({
    mixins: [
        HyperDropdownMixin,
        (typeof(OnClickOutside) !== "undefined" ? OnClickOutside : undefined)
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
        this.fetchTwitterCount();
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
        $.getJSON(`https://cdn.api.twitter.com/1/urls/count.json?url=${this.props.url}&callback=?`, data => {
            this.updateCount('twitter', data.count);
        });
    },

    totalShares: function () {
        return Object.keys(this.state.counts)
                .map(k => {return this.state.counts[k]})
                .reduce((a, b) => {
                    return a + b;
                });
    },

    render: function () {
        const { openState, renderLeft, counts } = this.state;
        const { title, shareUrls } = this.props;
        const dropdownClass = `dropdown ${(openState ? 'dropdown-active' : '')} ${this.props.dropdownClass || ''}`;

        let totalSharesCounter = <div className="notification-counter share-counter">{this.totalShares()}</div>;

        const trigger = (<a href={this.props.defaultAction}
                            className="dropdown-trigger"
                            onClick={this.handleClick}
                            done={this.close}
                            data-skip-pjax="true">
            <span className="fa fa-share-alt"></span>
            <span className="icon-left">{title}</span>
            {this.totalShares() > 0 && totalSharesCounter}
        </a>);

        let dropdownContent = <DropdownContent renderLeft={renderLeft}
                                               close={this.close}
                                               {...this.props}
                                               key='required' >
            <FBShareItem
                    shareUrl={shareUrls.facebook}
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
            </DropdownContent>;

        const ReactTransitionGroup = React.addons.TransitionGroup;
        return (<li tabIndex="1"
                    className={dropdownClass}
                    onMouseEnter={this.onMouseEnter}
                    onMouseLeave={this.onMouseLeave} >
            {trigger}
            <div className="reference-elem" style={{visibility: 'hidden', overflow: 'hidden', 'pointer-events': 'none', position: 'absolute'}}>{dropdownContent}</div>
            <ReactTransitionGroup transitionName="dropdown" transitionAppear={true} component="div">
                {openState && dropdownContent}
            </ReactTransitionGroup>
        </li>);
    }
});
window.ShareDropdown = ShareDropdown;

export var DropdownContent = React.createClass({
    getInitialState: function () {
        return {
            appearState: ''
        };
    },

    componentWillEnter: function (callback) {
        this.setState(
            {appearState: 'dropdown-enter'}, () => {
            window.setTimeout(() => {
                this.setState({appearState: 'dropdown-enter dropdown-enter-active'}, callback);
            }, 10);
        });
    },

    componentWillLeave: function (callback) {
        this.setState(
            {appearState: 'dropdown-leave'}, () => {
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
        if (typeof this.props.children !== "undefined") {
            children = this.props.children;
        } else {
            children = sections.map((section, i) => {
                if (typeof(section.type) === "string") {
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

        return (<div>
            <ul className={'dropdown-content ' + collapseClass + contentClassName + ' ' + this.state.appearState} style={null}>
                {children}
            </ul>
        </div>);
    }
});
window.HyperDropdown = HyperDropdown;

var LinkItem = React.createClass({
    getInitialState: function () {
        return {};
    },

    handleMouseDown: function () {
        // Fixes an issue where firefox bubbles events instead of capturing them
        // See: https://github.com/facebook/react/issues/2011
        let dataMethod = this.getDOMNode().getAttribute('data-method');
        if (dataMethod !== "post" && dataMethod !== "put" && dataMethod !== "patch" && dataMethod !== "delete") {
            this.getDOMNode().getElementsByTagName('a')[0].click();
            this.props.done();
        }
    },

    render: function () {
        var divider;
        if (this.props.divider && this.props.divider == 'top') {
            divider = <div className="dropdown-divider"></div>;
        }
        var method, confirm, remote, skipPjax, sortValue, className, displaySetting;
        if (this.props.data) {
            method = this.props.data.method;
            confirm = this.props.data.confirm;
            remote = this.props.data.remote;
            skipPjax = this.props.data['skip-pjax'];
            sortValue = this.props.data['sort-value'];
            displaySetting = this.props.data['display-setting'];
        }
        className = this.props.className;

        return (<li className={this.props.type}>
            {divider}
            <a href={this.props.url} data-remote={remote} data-method={method} data-confirm={confirm} onMouseDownCapture={this.handleMouseDown} data-skip-pjax={skipPjax} data-sort-value={sortValue} data-display-setting={displaySetting} className={className}>
                {image(this.props)}
                <span className={(this.props.image || this.props.fa) ? 'icon-left' : ''}>{this.props.title}</span>
            </a>
        </li>);
    }
});

var FBShareItem = React.createClass({
    handleClick: function (e) {
        if (typeof(FB) !== "undefined") {
            e.preventDefault();
            FB.ui({
                method: 'share',
                href: this.props.shareUrl,
                caption: this.props.title
            }, (response) => {
                console.log(response);
                this.props.done();
            });
        }
    },

    countInParentheses: function () {
        return this.props.count > 0 ? `(${this.props.count})` : '';
    },

    render: function () {
        return (<li className={this.props.type}>
            <a href={this.props.url} data-skip-pjax="true" onClick={this.handleClick}>
                {image({fa: 'fa-facebook'})}
                <span className="icon-left">Facebook {this.countInParentheses()}</span>
            </a>
        </li>);
    }
});

var ActorItem = React.createClass({
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
        }).catch(console.log);
    },
    
    handleTap: function (e) {
        this.switchActor();
    },

    handleMouseDown: function (e) {
        e.preventDefault();
        this.switchActor();
    },

    render: function () {
        var divider;
        if (this.props.divider && this.props.divider == 'top') {
            divider = <div className="dropdown-divider"></div>;
        }
        var method, remote, skipPjax;
        if (this.props.data) {
            skipPjax = this.props.data['skip-pjax'];
        }

        return (<li className={'link ' + this.props.type}>
            {divider}
            <a href='#' onMouseDownCapture={this.handleMouseDown} rel="nofollow" onTouchEnd={this.handleTap} onClickCapture={this.handleClick} data-skip-pjax={skipPjax}>
                {image(this.props)}
                <span className={(this.props.image || this.props.fa) ? 'icon-left' : ''}>{this.props.title}</span>
            </a>
        </li>);
    }
});

var CurrentUserTrigger = React.createClass({
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
        var triggerClass = "dropdown-trigger " + this.props.triggerClass;
        var TriggerContainer = this.props.triggerTag || 'div';

        return (<TriggerContainer className={triggerClass} onClick={this.props.handleClick} onTouchEnd={this.props.handleTap} >
            {image({image: {url: this.state.profile_photo.url, title: this.state.profile_photo.title, className: 'profile-picture--navbar'}})}
            <span className="icon-left">{this.state.display_name}</span>
        </TriggerContainer>);
    }
});

