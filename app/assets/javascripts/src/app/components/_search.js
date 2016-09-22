/*global $, Bugsnag*/
import Alert from './Alert';
import React from 'react';
import Select from 'react-select';
import { SingleValue } from './_membership';
import { safeCredentials, statusSuccess, json } from '../lib/helpers';

const FETCH_TIMEOUT_AMOUNT = 500;

export const MotionOption = React.createClass({
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
                {obj.label}
            </div>
        );
    }
});
window.MotionOption = MotionOption;

export const MotionSelect = React.createClass({
    propTypes: {
        display_name: React.PropTypes.string,
        forum: React.PropTypes.string,
        image: React.PropTypes.string
    },

    getInitialState () {
        this.currentFetchTimer = 0;
        return {
            display_name: this.props.display_name,
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
            const params = {
                q: input,
                thing: 'motion'
            };
            fetch(`/${this.props.forum}/m.json?${$.param(params)}`, safeCredentials())
                .then(statusSuccess)
                .then(json)
                .then(data => {
                    callback(null, {
                        options: data.data.map(motion => {
                            return {
                                id: motion.id.toString(),
                                value: motion.id.toString(),
                                name: motion.attributes.displayName,
                                label: motion.attributes.displayName
                            };
                        }),
                        complete: false
                    });
                }).catch(e => {
                    Alert('Server error occured, please try again later', 'alert', true);
                    Bugsnag.notifyException(e);
                    callback(null, { options: [], complete: false });
                });
        }, FETCH_TIMEOUT_AMOUNT);
    },

    filterOptions (results, filter, currentValues) {
        return results || currentValues;
    },

    render () {
        return (<Select
            name="question_answer[motion_id]"
            placeholder="Select motion"
            matchProp="any"
            ignoreCase={true}
            filterOptions={this.filterOptions}
            optionComponent={MotionOption}
            singleValueComponent={SingleValue}
            asyncOptions={this.loadOptions} />);
    }
});
window.MotionSelect = MotionSelect;
