import React from 'react';
import I18n from 'i18n-js';
import { safeCredentials, statusSuccess, json } from '../lib/helpers';

export const BearerTokens = React.createClass({
    propTypes: {
        createTokenUrl: React.PropTypes.string,
        groupId: React.PropTypes.number,
        indexTokenUrl: React.PropTypes.string
    },

    getInitialState () {
        return {
            tokens: undefined
        };
    },

    componentDidMount () {
        const { indexTokenUrl } = this.props;
        fetch(`${indexTokenUrl}/g/${this.props.groupId}`, safeCredentials())
            .then(statusSuccess)
            .then(json)
            .then(data => {
                this.setState({ tokens: data.data });
            });
    },

    handleCreateToken () {
        const { createTokenUrl, groupId } = this.props;
        fetch(createTokenUrl,
              safeCredentials({
                  method: 'POST',
                  body: JSON.stringify({
                      data: {
                          type: 'bearerToken',
                          attributes: {
                              group_id: groupId
                          }
                      }
                  })
              }))
            .then(statusSuccess)
            .then(json)
            .then(data => {
                this.setState({
                    tokens: this.state.tokens.concat(data.data)
                });
            });
    },

    onRetract (token) {
        this.setState({
            tokens: this.state.tokens.filter(i => { return i.id !== token.id })
        });
    },

    render () {
        return (
            <div className="formtastic">
                <TokenList
                    retractHandler={this.onRetract}
                    tokens={this.state.tokens}/>
                <fieldset className="actions">
                    <button
                        onClick={this.handleCreateToken}
                        type="submit"
                        value="Submit"> {I18n.t('tokens.generate')} </button>
                </fieldset>
            </div>
        );
    }
});
window.BearerTokens = BearerTokens;

export const TokenList = React.createClass({
    propTypes: {
        retractHandler: React.PropTypes.func,
        tokens: React.PropTypes.array
    },

    render () {
        const { retractHandler, tokens } = this.props;
        if (tokens === undefined) {
            return <p>{I18n.t('tokens.loading')}</p>;
        } else if (tokens.length === 0) {
            return <p>{I18n.t('tokens.bearer.empty')}</p>;
        }
        const rows = tokens.map(token => {
            return <Token key={token.id} retractHandler={retractHandler} token={token}/>;
        });
        return (
            <table>
                <thead className="subtle">
                <tr>
                    <td>{I18n.t('tokens.labels.link')}</td>
                    <td>{I18n.t('tokens.labels.usages')}</td>
                    <td></td>
                </tr>
                </thead>
                <tbody>
                    {rows}
                </tbody>
            </table>
        );
    }
});
window.TokenList = TokenList;

export const Token = React.createClass({
    propTypes: {
        retractHandler: React.PropTypes.func,
        token: React.PropTypes.object
    },

    handleRetract () {
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
        return (<tr>
            <td>
                <input readOnly='true' value={links.self}/>
            </td>
            <td>
                {attributes.usages}
            </td>
            <td>
                <a href='#' onClick={this.handleRetract}>{I18n.t('tokens.retract.button')}</a>
            </td>
        </tr>)
    }
});
