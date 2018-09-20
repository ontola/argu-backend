import React from 'react';
import I18n from 'i18n-js';
import { safeCredentialsJsonApi, statusSuccess, json } from '../lib/helpers';
import TokenList from './TokenList';
import 'whatwg-fetch';

export const BearerTokens = React.createClass({
    propTypes: {
        createTokenUrl: React.PropTypes.string,
        groupId: React.PropTypes.number,
        indexTokenUrl: React.PropTypes.string,
        rootId: React.PropTypes.number
    },

    getInitialState () {
        return {
            shouldLoadPage: false,
            submitting: false
        };
    },

    componentDidMount () {
        this.setState({ shouldLoadPage: true });
    },

    handleCreateToken () {
        const { createTokenUrl, groupId, rootId } = this.props;
        this.setState({ submitting: true });
        fetch(createTokenUrl,
              safeCredentialsJsonApi({
                  method: 'POST',
                  body: JSON.stringify({
                      data: {
                          type: 'bearerToken',
                          attributes: {
                              group_id: groupId,
                              root_id: rootId
                          }
                      }
                  })
              }))
            .then(statusSuccess)
            .then(json)
            .then(() => {
                this.setState({ shouldLoadPage: true, submitting: false });
            });
    },

    handlePageLoaded () {
        this.setState({ shouldLoadPage: false });
    },

    onRetract () {
        this.setState({ shouldLoadPage: true });
    },

    render () {
        return (
            <div className={`formtastic ${this.state.submitting ? 'is-loading' : ''}`}>
                <TokenList
                    columns={['link', 'usages']}
                    onPageLoaded={this.handlePageLoaded}
                    shouldLoadPage={this.state.shouldLoadPage}
                    iri={`${this.props.indexTokenUrl}/g/${this.props.groupId}`}
                    retractHandler={this.onRetract}/>
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

export default BearerTokens;
