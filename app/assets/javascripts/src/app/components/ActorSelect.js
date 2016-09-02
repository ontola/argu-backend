/*global Bugsnag*/
import Alert from './Alert';
import React from 'react';
import Select from 'react-select';
import { safeCredentials, statusSuccess, json } from '../lib/helpers';

const FETCH_TIMEOUT_AMOUNT = 500;

export const ActorOption = React.createClass({
    propTypes: {
        addLabelText: React.PropTypes.string,
        className: React.PropTypes.string,
        mouseDown: React.PropTypes.func,
        mouseEnter: React.PropTypes.func,
        mouseLeave: React.PropTypes.func,
        option: React.PropTypes.object.isRequired,
        renderFunc: React.PropTypes.func
    },

    handleMouseDown (e) {
        this.props.mouseDown(this.props.option, e);
    },

    handleMouseEnter (e) {
        this.props.mouseEnter(this.props.option, e);
    },

    handleMouseLeave (e) {
        this.props.mouseLeave(this.props.option, e);
    },

    render () {
        const { option, className } = this.props;

        return option.userId ? (
            <div className={className}
                 onMouseDown={this.handleMouseDown}
                 onMouseEnter={this.handleMouseEnter}
                 onMouseLeave={this.handleMouseLeave}>
                <img className="Select-item-result-icon" height='25em' src={option.image} />
                {`${option.userName} (${option.groupName})`}
            </div>
        ) : (
            <div className={className}
                 onMouseDown={this.handleMouseDown}
                 onMouseEnter={this.handleMouseEnter}
                 onMouseLeave={this.handleMouseLeave}>
                {option.groupName}
            </div>
        );
    }
});
window.ActorOption = ActorOption;

const SingleValue = props => {
    const obj = props.value;
    let item = props.placeholder;
    if (obj) {
        item = obj.userId ? (
            <div>
                <img className="Select-item-result-icon" height='25em' src={obj.image}/>
                {`${obj.userName} (${obj.groupName})`}
            </div>
        ) : <div>{obj.groupName}</div>;
    }

    return (
        <div className="Select-placeholder">
            {item}
        </div>);
};

SingleValue.propTypes = {
    placeholder: React.PropTypes.string,
    value: React.PropTypes.object
};

export { SingleValue };
window.SingleValue = SingleValue;

export const ActorSelect = React.createClass({
    propTypes: {
        display_name: React.PropTypes.string,
        groups: React.PropTypes.arrayOf(React.PropTypes.shape({
            disabled: React.PropTypes.bool,
            fontSize: React.PropTypes.number
        })),
        image: React.PropTypes.object,
        thing: React.PropTypes.string
    },

    getInitialState () {
        this.currentFetchTimer = 0;
        return {
            displayName: this.props.display_name,
            image: this.props.image
        };
    },

    componentWillUnmount () {
        window.clearTimeout(this.currentFetchTimeout);
    },

    handleChange (val) {
        document.getElementById('decision_forwarded_group_id').value = val.split('.')[0];
        if (val.split('.')[1] === undefined) {
            document.getElementById('decision_forwarded_user_id').value = '';
        } else {
            document.getElementById('decision_forwarded_user_id').value = val.split('.')[1];
        }
    },

    loadOptions (input, callback) {
        input = input.toLowerCase();
        if (!input.length) {
            return callback(null, {
                options: this.props.groups,
                complete: false
            });
        }

        window.clearTimeout(this.currentFetchTimeout);
        this.currentFetchTimeout = window.setTimeout(() => {
            fetch(`/${this.props.thing}/group_memberships.json`, safeCredentials({
                method: 'POST',
                body: JSON.stringify({
                    q: input,
                    thing: this.props.thing
                })
            })).then(statusSuccess)
                .then(json)
                .then(data => {
                    callback(null, {
                        options: this.filteredGroups(input).concat(
                            data.data.map(result => {
                                const gId = result.relationships.group.data.id;
                                const uId = result.relationships.user.data.id;
                                const gAttrs = data
                                    .included
                                    .find(obj => {
                                        return obj.type === 'groups' && obj.id === gId;
                                    })
                                    .attributes;
                                const uAttrs = data
                                    .included
                                    .find(obj => {
                                        return obj.type === 'users' && obj.id === uId;
                                    })
                                    .attributes;
                                return {
                                    value: [gId, uId].join('.'),
                                    groupId: gId.toString(),
                                    groupName: gAttrs.displayName,
                                    userId: uId.toString(),
                                    userName: uAttrs.displayName,
                                    image: uAttrs.profilePhoto.image.url
                                };
                            })),
                        complete: false
                    });
                }).catch(e => {
                    Alert('Server error occured, please try again later', 'alert', true);
                    Bugsnag.notifyException(e);
                    callback();
                });
        }, FETCH_TIMEOUT_AMOUNT);
        return this.currentFetchTimeout;
    },

    filterOptions (results, filter, currentValues) {
        return results || currentValues;
    },

    filteredGroups (input) {
        return this.props.groups.filter(group => {
            return (!group.disabled && group.groupName.toLowerCase().indexOf(input) > -1);
        });
    },

    render () {
        return (<Select asyncOptions={this.loadOptions}
                        filterOptions={this.filterOptions}
                        ignoreCase={true}
                        matchProp="any"
                        name="actor"
                        onChange={this.handleChange}
                        optionComponent={ActorOption}
                        options={this.props.groups}
                        placeholder="Select group or user"
                        singleValueComponent={SingleValue} />);
    }
});
window.ActorSelect = ActorSelect;
