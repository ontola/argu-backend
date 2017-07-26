/*global $*/
import React from 'react';
import SearchSelect from './SearchSelect';
import { safeCredentials } from '../lib/helpers';

export const SearchMotion = React.createClass({
    propTypes: {
        forum: React.PropTypes.string.isRequired,
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
        this.setState({ value: value.value });
    },

    fetchResults (input) {
        const params = {
            q: input,
            thing: 'motion'
        };
        return fetch(`/${this.props.forum}/m/search.json?${$.param(params)}`, safeCredentials())
    },

    filterResults (data) {
        return data.data.map(motion => {
            return {
                value: motion.id.toString().split('/').pop(),
                label: motion.attributes.name
            };
        });
    },

    render () {
        return (<SearchSelect
            fetchResults={this.fetchResults}
            fieldName="question_answer[motion_id]"
            filterResults={this.filterResults}
            onChange={this.handleChange}
            placeholder="Select motion"
            things={this.props.things}
            value={this.state.value}/>);
    }
});
window.SearchMotion = SearchMotion;
