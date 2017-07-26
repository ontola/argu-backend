import React from 'react';
import SearchSelect from './SearchSelect';
import { safeCredentials } from '../lib/helpers';

export const SearchActor = React.createClass({
    propTypes: {
        groups: React.PropTypes.arrayOf(React.PropTypes.shape({
            disabled: React.PropTypes.bool,
            groupId: React.PropTypes.number,
            groupName: React.PropTypes.string,
            value: React.PropTypes.string
        })),
        thing: React.PropTypes.string,
        value: React.PropTypes.string
    },

    getInitialState () {
        return {
            value: this.props.value
        }
    },

    handleChange (val) {
        this.setState({ value: val.value });
        document.getElementById('decision_forwarded_group_id').value = val.value.split('.')[0];
        if (val.value.split('.')[1] === undefined) {
            document.getElementById('decision_forwarded_user_id').value = '';
        } else {
            document.getElementById('decision_forwarded_user_id').value = val.value.split('.')[1];
        }
    },

    fetchResults (input) {
        return fetch(`/${this.props.thing}/group_memberships.json`, safeCredentials({
            method: 'POST',
            body: JSON.stringify({
                q: input,
                thing: this.props.thing
            })
        }))
    },

    filteredGroups (input) {
        return this.props.groups.filter(group => {
            return (!group.disabled && group.label.toLowerCase().indexOf(input) > -1);
        });
    },

    filterResults (data, input) {
        return this.filteredGroups(input).concat(
            data.data.map(result => {
                const gId = result.relationships.group.data.id;
                const uId = result.relationships.user.data.id;
                const gAttrs = data
                    .included
                    .find(obj => {
                        return obj.type === 'groups' && obj.id === gId;
                    })
                    .attributes;
                const user = data
                    .included
                    .find(obj => {
                        return obj.type === 'users' && obj.id === uId;
                    });
                const uAttrs = user.attributes;
                const pAttrs = data
                    .included
                    .find(obj => {
                        return obj.type === 'schema:ImageObject' &&
                            obj.id === user.relationships.profilePhoto.data.id;
                    })
                    .attributes;
                return {
                    value: [gId.split('/').pop(), uId.split('/').pop()].join('.'),
                    label: `${uAttrs.displayName} (${gAttrs.displayName})`,
                    image: pAttrs.thumbnail
                };
            })
        );
    },

    render () {
        return (<SearchSelect
            fetchResults={this.fetchResults}
            fieldName="actor"
            filterResults={this.filterResults}
            onChange={this.handleChange}
            options={this.props.groups}
            placeholder="Select group or user"
            value={this.state.value}/>);
    }

});
window.SearchActor = SearchActor;
