/*global Bugsnag*/
import Alert from './Alert';
import React from 'react';
import Select from 'react-select';
import { statusSuccess, json } from '../lib/helpers';

const FETCH_TIMEOUT_AMOUNT = 500;

const SearchSelect = React.createClass({
    propTypes: {
        fetchResults: React.PropTypes.func,
        fieldName: React.PropTypes.string.isRequired,
        filterResults: React.PropTypes.func,
        multi: React.PropTypes.bool,
        onChange: React.PropTypes.func,
        options: React.PropTypes.array,
        placeholder: React.PropTypes.string,
        things: React.PropTypes.string,
        values: React.PropTypes.array
    },

    componentWillUnmount () {
        window.clearTimeout(this.currentFetchTimeout);
    },

    loadOptions (input, callback) {
        if (typeof input !== 'string') {
            return null;
        }
        input = input.toLowerCase();
        if (!input.length) {
            return callback(null, {
                options: this.props.options,
                complete: false
            });
        } else {
            window.clearTimeout(this.currentFetchTimeout);
            this.currentFetchTimeout = window.setTimeout(() => {
                this.props.fetchResults(input.toLowerCase())
                    .then(statusSuccess)
                    .then(json)
                    .then(data => {
                        callback(null, { options: this.props.filterResults(data, input), complete: false });
                    }).catch(e => {
                        Alert('Server error occured, please try again later', 'alert', true);
                        Bugsnag.notifyException(e);
                        callback();
                    });
            }, FETCH_TIMEOUT_AMOUNT);
        }
    },

    valueRenderer (obj) {
        return (obj.image !== undefined) ? (
            <div>
                <img className="Select-item-result-icon" height='25em' src={obj.image} width='25em'/>
                {obj.label}
            </div>
        ) : <div> {obj.label} </div>;
    },

    filterOptions (results, filter, currentValues) {
        return results || currentValues;
    },

    render () {
        return (<Select
                  asyncOptions={this.loadOptions}
                  filterOptions={this.filterOptions}
                  ignoreCase={true}
                  matchProp="any"
                  multi={this.props.multi}
                  name={this.props.fieldName}
                  onChange={this.props.onChange}
                  optionRenderer={this.valueRenderer}
                  options={this.props.options}
                  placeholder={this.props.placeholder}
                  singleValueRenderer={this.valueRenderer}
                  value={this.props.values}
                  valueRenderer={this.valueRenderer}
                  values={this.props.values}/>);
    }
});
export default SearchSelect
window.SearchSelect = SearchSelect;
