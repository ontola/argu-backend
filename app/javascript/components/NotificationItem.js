import React from 'react';
import 'whatwg-fetch';

import { NotificationActions } from './stores/notification_store';
import { image } from './lib/helpers';
import { safeCredentials, statusSuccess, json } from './lib/helpers';

export const NotificationItem = React.createClass({
    propTypes: {
        created_at: React.PropTypes.string,
        creator: React.PropTypes.shape({
            avatar: React.PropTypes.object
        }),
        data: React.PropTypes.shape({
            remote: React.PropTypes.string,
            method: React.PropTypes.string,
            'turbolinks': React.PropTypes.string,
            type: React.PropTypes.string
        }),
        done: React.PropTypes.func,
        fa: React.PropTypes.string,
        id: React.PropTypes.number,
        image: React.PropTypes.object,
        read: React.PropTypes.bool,
        title: React.PropTypes.string,
        type: React.PropTypes.string,
        url: React.PropTypes.string
    },

    getInitialState () {
        return {};
    },

    handleClick (e) {
        e.stopPropagation();
        fetch(`/n/${this.props.id}.json`, safeCredentials({
            method: 'PUT'
        })).then(statusSuccess)
          .then(json)
          .then(data => {
              NotificationActions.notificationUpdate(data.notifications);
          }).catch(err => {
            throw err;
        });
        this.props.done();
    },

    render () {
        let method, remote, turbolinks;
        const className = [this.props.type, this.props.read ? 'read' : 'unread'].join(' ');
        if (this.props.data) {
            method = this.props.data.method;
            remote = this.props.data.remote;
            turbolinks = this.props.data['turbolinks'];
        }

        return (<li className={`notification-item ${className}`}>
            <a href={this.props.url} data-remote={remote} data-method={method} onClick={this.handleClick} data-turbolinks={turbolinks}>
                <img src={this.props.creator.avatar.url} className="notification-avatar" />
                <span className='notification-description'>{this.props.title}</span>
                <div className='notification-bottom'>
                    <span className={(this.props.image || this.props.fa) ? 'icon-left' : ''}>{this.props.created_at}</span>
                    {image(this.props)}
                </div>
            </a>
        </li>);
    }
});

export default NotificationItem;
