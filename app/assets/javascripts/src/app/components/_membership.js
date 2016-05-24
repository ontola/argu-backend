/*global Bugsnag*/
import Alert from './Alert';
import React from 'react';
import Select from 'react-select';
import { safeCredentials, statusSuccess, json } from '../lib/helpers';

const FETCH_TIMEOUT_AMOUNT = 500;

export const ProfileOption = React.createClass({
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
        const obj = this.props.option;

        return (
                <div className={this.props.className}
                     onMouseEnter={this.handleMouseEnter}
                     onMouseLeave={this.handleMouseLeave}
                     onMouseDown={this.handleMouseDown}>
                    <img className="Select-item-result-icon" height='25em' src={obj.image} />
                    {obj.label} ({obj.value})
                </div>
        );
    }
});
window.ProfileOption = ProfileOption;

export const SingleValue = React.createClass({
    propTypes: {
        placeholder: React.PropTypes.string,
        value: React.PropTypes.object
    },
    render () {
        const obj = this.props.value;

        const item = obj ? (
            <div>
                <img className="Select-item-result-icon" height='25em' src={obj.image} />
                {obj.label} ({obj.value})
            </div>
        ) : (this.props.placeholder);

        return (
            <div className="Select-placeholder">
                {item}
            </div>);
    }
});
window.SingleValue = SingleValue;

export const NewMembership = React.createClass({
    propTypes: {
        display_name: React.PropTypes.string,
        thing: React.PropTypes.string,
        things: React.PropTypes.string,
        image: React.PropTypes.string
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

    loadOptions (input, callback) {
        input = input.toLowerCase();
        if (!input.length) {
            return callback(null, {
                options: [],
                complete: false
            });
        }

        window.clearTimeout(this.currentFetchTimeout);
        this.currentFetchTimeout = window.setTimeout(() => {
            fetch('/profiles.json', safeCredentials({
                method: 'POST',
                body: JSON.stringify({
                    q: input,
                    thing: this.props.thing,
                    things: this.props.things
                })
            })).then(statusSuccess)
               .then(json)
               .then(data => {
                   callback(null, {
                       options: data.profiles.map(profile => ({
                           id: profile.id.toString(),
                           value: profile.shortname,
                           label: profile.name,
                           image: profile.profile_photo.avatar.url
                       })),
                       complete: false
                   });
               }).catch(e => {
                   Alert('Server error occured, please try again later', 'alert', true);
                   Bugsnag.notifyException(e);
                   callback();
               });
        }, FETCH_TIMEOUT_AMOUNT);
    },

    filterOptions (results, filter, currentValues) {
        return results || currentValues;
    },

    render () {

        return (<Select
                  name="profile_id"
                  placeholder="Select user"
                  matchProp="any"
                  ignoreCase={true}
                  filterOptions={this.filterOptions}
                  optionComponent={ProfileOption}
                  singleValueComponent={SingleValue}
                  asyncOptions={this.loadOptions} />);
    }
});
window.NewMembership = NewMembership;
