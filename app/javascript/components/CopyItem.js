import Alert from './Alert';
import Clipboard from 'clipboard';
import I18n from 'i18n-js';
import React from 'react';

import { image } from './lib/helpers';

export const CopyItem = React.createClass({
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

    componentDidMount () {
        this.clipboard = new Clipboard('.copy-btn');
    },

    componentWillUnmount () {
        this.clipboard.destroy();
    },

    handleClick (e) {
        e.preventDefault();
        this.props.done()
    },

    handleMouseDown (e) {
        e.preventDefault();
        new Alert(I18n.t('menus.copy_successful', { url: this.props.url }), 'notice', true);
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
            <a className="copy-btn"
               data-clipboard-text={this.props.url}
               data-turbolinks={turbolinks}
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

export default CopyItem;
