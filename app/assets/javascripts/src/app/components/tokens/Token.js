import React from 'react';
import I18n from 'i18n-js';
import { safeCredentials, statusSuccess } from '../../lib/helpers';

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
            } else {
                return <td key={column}>{attributes[column]}</td>;
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
