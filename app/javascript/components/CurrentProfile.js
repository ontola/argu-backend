import React from 'react';
import Select from 'react-select';
import I18n from 'i18n-js';

export const CurrentProfile = React.createClass({
    propTypes: {
        action: React.PropTypes.string,
        currentActor: React.PropTypes.number,
        managedProfiles: React.PropTypes.array
    },

    getInitialState () {
        return {
            currentActor: this.props.currentActor
        };
    },

    onProfileChange (value) {
        this.setState({ currentActor: value.value })
    },

    optionRenderer (obj) {
        return (
            <div>
                <img className="Select-item-result-icon" height='25em' src={obj.image} width='25em'/>
                {obj.label}
            </div>
        );
    },

    valueRenderer (obj) {
        return (
            <div>
                <span className="post-as">{I18n.t(`profiles.actor.${this.props.action}`)}</span>
                <img className="Select-item-result-icon" height='25em' src={obj.image} width='25em'/>
                {obj.label}
            </div>
        );
    },

    render () {
        if (this.props.managedProfiles.length === 1) {
            const obj = this.props.managedProfiles[0];
            return (
                <div className="Select Select-profile has-value">
                    <div className="Select-control">
                        <div className="Select-value">
                            <img className="Select-item-result-icon" height='25em' src={obj.image} width='25em'/>
                            {obj.label}
                        </div>
                        <div className="Select-input" style={{ display: 'inline-block' }}/>
                    </div>
                </div>
            );
        }
        return (
            <div>
                <Select
                    className="Select-profile"
                    clearable={false}
                    matchProp="any"
                    name='actor_iri'
                    onChange={this.onProfileChange}
                    optionRenderer={this.optionRenderer}
                    options={this.props.managedProfiles}
                    placeholder="Select user"
                    value={this.state.currentActor}
                    valueRenderer={this.valueRenderer}/>
            </div>
        );
    }
});

export default CurrentProfile;
