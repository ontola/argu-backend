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

    filterResults (data) {
        return data.profiles.map(profile => {
            return {
                value: profile.shortname,
                label: `${profile.name} (${profile.shortname})`,
                image: profile.profile_photo.avatar.url
            };
        });
    },

    render () {
        return (<SearchSelect
            fetchResults={this.fetchResults}
            fieldName={this.props.fieldName}
            filterResults={this.filterResults}
            multi={this.props.multi}
            onChange={this.handleChange}
            placeholder="Select user"
            things={this.props.things}
            value={this.state.value}/>);
    }
});

export default SearchUser;
