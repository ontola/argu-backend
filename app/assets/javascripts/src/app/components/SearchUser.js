import React from 'react';
import SearchSelect from './SearchSelect';
import { safeCredentials } from '../lib/helpers';

export const SearchUser = React.createClass({
    propTypes: {
        fieldName: React.PropTypes.string.isRequired,
        multi: React.PropTypes.bool,
        things: React.PropTypes.string,
        values: React.PropTypes.array
    },

    getInitialState () {
        return {
            values: this.props.values
        }
    },

    handleChange (_, values) {
        this.setState({ values });
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
            values={this.state.values}/>);
    }
});
window.SearchUser = SearchUser;
