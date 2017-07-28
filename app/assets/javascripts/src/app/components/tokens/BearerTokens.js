import React from 'react';
import I18n from 'i18n-js';
import { safeCredentials, statusSuccess, json } from '../../lib/helpers';
import TokenList from './TokenList';

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
                    columns={['link', 'usages']}
                    emptyString={I18n.t('tokens.bearer.empty')}
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
