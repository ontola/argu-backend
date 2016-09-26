import React from 'react';
import I18n from 'i18n-js';
import { safeCredentials, statusSuccess, json } from '../lib/helpers';

export const BearerTokens = React.createClass({
    propTypes: {
        createTokenUrl: React.PropTypes.string,
        groupId: React.PropTypes.number
    },

    getInitialState () {
        return {
            tokens: undefined
        };
    },

    componentDidMount () {
        fetch(`/tokens/bearer/g/${this.props.groupId}`, safeCredentials())
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
                          type: 'bearer_token',
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
                    tokens={this.state.tokens}
                    webhook={this.state.webhook}/>
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

const tokenListProps = {
    retractHandler: React.PropTypes.func,
    tokens: React.PropTypes.array,
    webhook: React.PropTypes.object
};
const TokenList = props => {
    const { retractHandler, tokens } = props;
    const content = (tokens === undefined) ? <p>{I18n.t('tokens.loading')}</p> :
        <table>
            <thead>
            <tr>
                <td>{I18n.t('tokens.labels.link')}</td>
                <td>{I18n.t('tokens.labels.usages')}</td>
                <td></td>
            </tr>
            </thead>
            <tbody>
            {
                tokens.map(token => {
                    return <Token
                        key={token.id}
                        retractHandler={retractHandler}
                        token={token}/>
                })
            }
            </tbody>
        </table>;

    return (
        <div>
            <legend><span>{I18n.t('tokens.bearer.title')}</span></legend>
            <p>{I18n.t('tokens.bearer.description')}</p>
            {content}
        </div>
    )
};
TokenList.propTypes = tokenListProps;

export const Token = React.createClass({
    propTypes: {
        retractHandler: React.PropTypes.func,
        token: React.PropTypes.object
    },

    handleRetract () {
        if (window.confirm(I18n.t('tokens.retract.confirm')) === true) {
            fetch(this.props.token.links.url,
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
                <input disabled='true' value={links.url}/>
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
