import React from 'react';
import 'whatwg-fetch';

import SearchSelect from './SearchSelect';
import { safeCredentials } from './lib/helpers';

export const SearchUser = React.createClass({
    propTypes: {
        fieldName: React.PropTypes.string.isRequired,
        multi: React.PropTypes.bool,
        things: React.PropTypes.string,
        value: React.PropTypes.string
    },

    getInitialState () {
        return {
            value: this.props.value
        }
    },

    handleChange (value) {
        this.setState({ value });
    },

    fetchResults (input) {
        return fetch('/profiles.json', safeCredentials({
            method: 'POST',
            body: JSON.stringify({
                q: input,
                things: this.props.things
            })
        }))
    },

    filterResults (data, query) {
        return data.profiles.map(profile => {
            const label = (query.indexOf('@') !== -1) ? `${profile.name} (${profile.email})` : `${profile.name} (${profile.shortname})`;
            return {
                image: profile.profile_photo.avatar.url,
                iri: profile.url,
                label,
                value: profile.shortname
            };
        });
    },

    handleOnClick (e) {
        e.preventDefault();
        debugger;
        window.location = this.state.value.iri;
    },

    render () {
        return (
            <div className="input-with-button-wrapper">
                <SearchSelect
                    className="input-wrapper"
                    fetchResults={this.fetchResults}
                    fieldName={this.props.fieldName}
                    filterResults={this.filterResults}
                    multi={this.props.multi}
                    onChange={this.handleChange}
                    placeholder="Select user"
                    things={this.props.things}
                    value={this.state.value}/>
                <button className="btn" disabled={this.state.value === undefined} onClick={this.handleOnClick}>{">"}</button>
            </div>
        );
    }
});

export default SearchUser;
