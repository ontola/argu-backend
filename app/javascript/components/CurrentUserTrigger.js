import React from 'react';

import { image } from './lib/helpers';
import actorStore from './stores/actor_store';

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

export default CurrentUserTrigger;
