import I18n from 'i18n-js';
import React from 'react';

export const CustomGrantsForm = React.createClass({
    propTypes: {
        action: React.PropTypes.string,
        defaultGroupIds: React.PropTypes.array,
        grantsReset: React.PropTypes.boolean,
        groupIdsFieldName: React.PropTypes.string,
        groups: React.PropTypes.array,
        resetFieldName: React.PropTypes.string,
        resourceType: React.PropTypes.string,
        selectedGroupIds: React.PropTypes.array
    },

    getInitialState () {
        return {
            grantsReset: this.props.grantsReset,
            selectedGroupIds: this.props.selectedGroupIds
        };
    },

    handleGrantResetChange (value) {
        this.setState({ grantsReset: value.target.value === 'true' });
    },

    handleGroupIdsChange (value) {
        const selectedGroupIds = this.state.selectedGroupIds.slice();
        if (value.currentTarget.checked) {
            selectedGroupIds.push(parseInt(value.currentTarget.value));
        } else {
            const index = selectedGroupIds.indexOf(parseInt(value.currentTarget.value));
            selectedGroupIds.splice(index, 1);
        }
        this.setState({ selectedGroupIds });
    },

    render() {
        let selection;
        if (this.state.grantsReset === true) {
            selection = <li className="form-helper inline-checkboxes"><ol>
                {
                    this.props.groups.map(group => {
                        return (
                            <li className="choice" key={`group${group.id}`}>
                                <label>
                                    <input checked={this.state.selectedGroupIds.indexOf(group.id) >= 0}
                                           name={this.props.groupIdsFieldName}
                                           onChange={this.handleGroupIdsChange}
                                           type="checkbox"
                                           value={group.id}/>
                                    {group.displayName}
                                </label>
                            </li>
                        );
                    })
                }
            </ol></li>;
        } else {
            selection =
                <li className="form-helper">
                    {
                        this
                            .props
                            .groups
                            .filter(group => { return this.props.defaultGroupIds.indexOf(group.id) >= 0; })
                            .map(group => { return group.displayName })
                            .join(', ')
                    }
                </li>;
        }

        return (
            <div>
                <span className="label"><label>{I18n.t('grant_resets.label')}</label></span>
                <label>
                    <input name={this.props.resetFieldName}
                           type="radio"
                           value={false}
                           checked={this.state.grantsReset === false}
                           onChange={this.handleGrantResetChange}/>
                    {I18n.t('grant_resets.default')}
                </label>
                <label>
                    <input name={this.props.resetFieldName}
                           type="radio"
                           value={true}
                           checked={this.state.grantsReset === true}
                           onChange={this.handleGrantResetChange}/>
                    {I18n.t('grant_resets.manual')}
                </label>
                <input type="hidden" name={this.props.groupIdsFieldName} value=''/>
                {selection}
            </div>
        );
    }
});

export default CustomGrantsForm;
