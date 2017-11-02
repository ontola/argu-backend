import React from 'react';
import I18n from 'i18n-js';
import { safeCredentials, statusSuccess } from '../lib/helpers';

export const Token = React.createClass({
    propTypes: {
        columns: React.PropTypes.array,
        retractHandler: React.PropTypes.func,
        token: React.PropTypes.object
    },

    handleRetract (e) {
        e.preventDefault();
        if (window.confirm(I18n.t('tokens.retract.confirm')) === true) {
            fetch(this.props.token.links.self,
                safeCredentials({
                    method: 'DELETE'
                }))
                .then(statusSuccess)
                .then(this.props.retractHandler(this.props.token));
        }
    },

    render () {
        const { attributes, links } = this.props.token;
        const cells = this.props.columns.map(column => {
            if (column === 'link') {
                return <td key={column}><input readOnly='true' value={links.self}/></td>;
            } else if (column === 'isRead') {
                if (this.props.token.attributes.opened || this.props.token.attributes.clicked) {
                    return <td key={column}><span className="fa fa-check"/></td>;
                } else {
                    return <td key={column}/>;
                }
            } else {
                let icon;
                if (column === 'invitee' && this.props.token.attributes.status === 'failed') {
                    icon = <span className="fa fa-warning" data-title={I18n.t('tokens.email.delivery_failed')}/>
                } else if (column === 'invitee' && this.props.token.attributes.status === 'pending') {
                    icon = <span className="fa fa-hourglass-o" data-title={I18n.t('tokens.email.pending')}/>
                }
                return <td key={column}>{icon}{attributes[column]}</td>;
            }
        });
        return (
            <tr>
                {cells}
                <td><a href='#' onClick={this.handleRetract}>{I18n.t('tokens.retract.button')}</a></td>
            </tr>
        );
    }
});

export default Token;
