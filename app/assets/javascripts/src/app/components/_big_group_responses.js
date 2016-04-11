import Alert from './Alert';
import React from 'react';
import { IntlMixin } from 'react-intl';
//import 'intl/locale-data/jsonp/en.js';
import { safeCredentials, statusSuccess, json } from '../lib/helpers';

/**
 * For making a GroupResponse in a BigVote fashion.
 * @class
 * @export BigGroupResponse
 */
export const BigGroupResponse = React.createClass({
    mixins: [IntlMixin],

    getInitialState () {
        return {
            objectType: this.props.objectType,
            objectId: this.props.object_id,
            currentVote: this.props.current_vote,
            distribution: this.props.distribution,
            percent: this.props.percent
        };
    },

    refresh () {
        fetch(`${this.state.objectId}.json`, safeCredentials())
            .then(statusSuccess)
            .then(json)
            .then(data => {
                data.motion && this.setState(data.motion);
            }).catch(() => {
                Alert(this.getIntlMessage('errors.general'), 'alert', true);
            });
    },

    render () {
        return (<div className="motion-shr">
            {this.props.groups.map(group => {
                let respond, buttons;
                if (group.responses_left > 0) {
                    if (this.props.actor.name) {
                        respond = (<p className="group-response-pre center">Stem namens {this.props.actor.name} als {group.name_singular}:</p>);
                    }
                    else {
                        respond = (<p className="group-response-pre center">Stem als {group.name_singular}:</p>);
                    }

                    buttons = (
                        <ul className="btns-opinion center">
                            <li><a href={`${this.props.objectId}/groups/${group.id}/responses/new?side=pro`} rel="nofollow" className="btn-pro">
                                <span className="fa fa-thumbs-up" />
                                <span className="icon-left">Voor</span>
                            </a></li>
                            <li><a href={`${this.props.objectId}/groups/${group.id}/responses/new?side=neutral`} rel="nofollow" className="btn-neutral">
                                <span className="fa fa-pause" />
                                <span className="icon-left">Geen van beiden</span>
                            </a></li>
                            <li><a href={`${this.props.objectId}/groups/${group.id}/responses/new?side=con`} rel="nofollow" className="btn-con">
                                <span className="fa fa-thumbs-down" />
                                <span className="icon-left">Tegen</span>
                            </a></li>
                        </ul>
                    );
                }

                return (<div key={group.id}>
                    {respond}
                    {buttons}
                </div>);
            })}
        </div>);
    }
});
export default BigGroupResponse;

window.BigGroupResponse = BigGroupResponse;
