import React from 'react';
import ReactDOM from 'react-dom';

import { image } from './lib/helpers';

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

export default LinkItem;
