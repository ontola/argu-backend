import React from 'react';

import { image } from './lib/helpers';

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

export default ActorItem;
