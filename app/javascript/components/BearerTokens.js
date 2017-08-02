import I18n from 'i18n-js';
import React from 'react';
import 'whatwg-fetch';

import { safeCredentials, statusSuccess, json } from './lib/helpers';

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

export const TokenList = React.createClass({
    propTypes: {
        retractHandler: React.PropTypes.func,
        tokens: React.PropTypes.array
    },

    tbody () {
        const { retractHandler, tokens } = this.props;
        if (tokens === undefined) {
            return <tr><td>{I18n.t('tokens.loading')}</td></tr>;
        } else if (tokens.length === 0) {
            return <tr><td>{I18n.t('tokens.bearer.empty')}</td></tr>;
        } else {
            return tokens.map(token => {
                return <Token key={token.id} retractHandler={retractHandler} token={token}/>;
            });
        }
    },

    render () {
        return (
            <table>
                <thead>
                <tr>
                    <td>{I18n.t('tokens.labels.link')}</td>
                    <td>{I18n.t('tokens.labels.usages')}</td>
                    <td></td>
                </tr>
                </thead>
                <tbody>
                    {this.tbody()}
                </tbody>
            </table>
        );
    }
});

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

export default BearerTokens;
