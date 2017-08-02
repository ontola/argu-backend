import React from 'react';

import Notifications from './Notifications';
import LinkItem from './LinkItem';
import ActorItem from './ActorItem';
import FBShareItem from './FBShareItem';

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

export default DropdownContent;
