/**
 * Opinions
 * @module Opinions
 */

import React, { Component, PropTypes } from 'react'
import HyperDropdownMixin from '../mixins/HyperDropdownMixin';
import OnClickOutside from 'react-onclickoutside';
import ReactTransitionGroup from 'react-addons-transition-group';
import { reduxForm } from 'redux-form';
import { CheckboxGroup } from './FormFields';
import {
    safeCredentials,
    json,
    statusSuccess,
    tryLogin
} from '../lib/helpers';

/**
 * Component to ask for an opinion after a vote
 * @class OpinionForm
 * @memberof Opinions
 */
export let OpinionForm = React.createClass({
    mixins: [
        OnClickOutside
    ],

    propTypes: {
        arguments: React.PropTypes.arrayOf(React.PropTypes.shape({
            id: React.PropTypes.number,
            displayName: React.PropTypes.string,
            side: React.PropTypes.string
        })),
        currentVote: React.PropTypes.string,
        fields: PropTypes.object.isRequired,
        resetForm: PropTypes.func.isRequired,
        submitting: PropTypes.bool.isRequired,
        onClose: React.PropTypes.func,
        onSubmit: PropTypes.func.isRequired
    },

    handleClickOutside () {
        this.props.onClose();
    },

    onSubmit () {
        const opinion_arguments_ids = this.props.fields.opinionArguments.value.map(id => id);
        fetch(`${window.location.href}/opinions.json`, safeCredentials({
            method: 'POST',
            body: JSON.stringify({
                opinion: {
                    body: this.props.fields.body.value,
                    opinion_arguments_ids
                }
            })
        })).then(statusSuccess, tryLogin)
            .then(json);
    },
    
    render () {
        const {
            fields: { body, opinionArguments },
            onSubmit,
            submitting
        } = this.props;

        const argumentFields = {};
        argumentFields['pro'] = [];
        argumentFields['con'] = [];
        this.props.arguments.forEach(argument => {
            argumentFields[argument.side].push({ label: argument.displayName, value: argument.id });
        });

        return (
            <form className={`formtastic opinion-form opinion-form-${this.props.vote.side}`}
                  onSubmit={onSubmit}>
                <section>
                    <div>
                        <label>Bedankt voor je stem. Wil je jouw mening toelichten?</label>
                        <div>
                            <textarea
                                className="form-input-content"
                                {...body}
                                value={body.value || ''}/>
                        </div>
                    </div>
                    <div>
                        <label>Welke argumenten vind jij belangrijk?</label>
                        <CheckboxGroup
                            wrapperClass="box-list box-list--arguments box-list--icons"
                            childClass="pro-t tooltip--wider"
                            options={argumentFields['pro']}
                            {...opinionArguments}/>
                        <CheckboxGroup
                            wrapperClass="box-list box-list--arguments box-list--icons"
                            childClass="con-t tooltip--wider"
                            options={argumentFields['con']}
                            {...opinionArguments}/>
                    </div>
                    <div>
                        <button type="submit" disabled={submitting}>
                            {submitting ? <i/> : <i/>} Submit
                        </button>
                    </div>
                </section>
            </form>
        )
    }
});

OpinionForm = reduxForm({
    form: 'simple',
    fields: ['body', 'opinionArguments'],
    initialValues: {
        opinionArguments: []
    }

})(OpinionForm);

window.OpinionForm = OpinionForm;


/**
 * Component to render Opinions
 * @class OpinionsIndex
 * @memberof Opinions
 */
export const OpinionsIndex = React.createClass({
    propTypes: {
        arguments: React.PropTypes.arrayOf(React.PropTypes.shape({
            id: React.PropTypes.number,
            displayName: React.PropTypes.string,
            side: React.PropTypes.string
        })),
        currentVote: React.PropTypes.string,
        votes: React.PropTypes.object
    },

    render () {
        const { votes } = this.props;
        const render_votes = {
            pro: [],
            neutral: [],
            con: []
        };

        for (const id in votes) {
            render_votes[votes[id].side].push(<SingleVote key={votes[id].key} vote={votes[id]} />);
        }

        return (
            <div className="opinions">
                <div className="opinions-box opinions-pro">
                    {render_votes['pro']}
                </div>
                <div className="opinions-box opinions-neutral">
                    {render_votes['neutral']}
                </div>
                <div className="opinions-box opinions-con">
                    {render_votes['con']}
                </div>
            </div>
        );
    }
});
window.OpinionsIndex = OpinionsIndex;

/**
 * Component to render the content of an Opinion
 * @class OpinionContent
 * @memberof Opinions
 */
const ANIMATION_DURATION = 10;

export const OpinionContent = React.createClass({
    propTypes: {
        arguments: React.PropTypes.arrayOf(React.PropTypes.shape({
            id: React.PropTypes.number,
            displayName: React.PropTypes.string,
            side: React.PropTypes.string
        })),
        close: React.PropTypes.func,
        vote: React.PropTypes.shape({
            createdAt: React.PropTypes.string,
            id: React.PropTypes.number,
            key: React.PropTypes.string,
            opinion: React.PropTypes.shape({
                id: React.PropTypes.integer,
                body: React.PropTypes.string
            }),
            voter: React.PropTypes.shape({
                displayName: React.PropTypes.string,
                profilePhotoUrl: React.PropTypes.string,
                userUrl: React.PropTypes.string
            }),
            side: React.PropTypes.string
        })
    },

    getInitialState () {
        return {
            appearState: ''
        };
    },

    componentWillEnter (callback) {
        this.setState(
            { appearState: 'dropdown-enter' },
            () => {
                this.enterTimeout = window.setTimeout(() => {
                    this.setState({ appearState: 'dropdown-enter dropdown-enter-active' }, callback);
                }, ANIMATION_DURATION);
            }
        );
    },

    componentWillLeave (callback) {
        this.setState(
            { appearState: 'dropdown-leave' },
            () => {
                this.leaveTimeout = window.setTimeout(() => {
                    this.setState(
                        { appearState: 'dropdown-leave dropdown-leave-active' },
                        () => {
                            this.innerLeaveTimeout = window.setTimeout(callback, 200)
                        });
                }, 0);
            });
    },

    componentWillUnmount () {
        window.clearTimeout(this.enterTimeout);
        window.clearTimeout(this.leaveTimeout);
        window.clearTimeout(this.innerLeaveTimeout);
    },

    render () {
        const { vote } = this.props;
        
        if (vote.opinion !== null) {
            return (
                <div className={'dropdown-content ' + this.state.appearState}
                     style={null}>
                    <h4>{vote.voter.displayName}</h4>
                    <div>{vote.opinion.body}</div>
                </div>);
        }
        else {
            return (
                <div className={'dropdown-content ' + this.state.appearState}
                     style={null}>
                    <h4>{vote.voter.displayName}</h4>
                    <div>Geen toelichting</div>
                </div>
                )
            
        }
    }
});
window.OpinionContent = OpinionContent;

/**
 * Component to render one Opinion
 * @class SingleVote
 * @memberof Opinions
 */
export const SingleVote = React.createClass({
    mixins: [
        HyperDropdownMixin,
        OnClickOutside
    ],

    propTypes: {
        vote: React.PropTypes.shape({
            createdAt: React.PropTypes.string,
            id: React.PropTypes.number,
            key: React.PropTypes.string,
            opinion: React.PropTypes.shape({
                id: React.PropTypes.integer,
                body: React.PropTypes.string
            }),
            voter: React.PropTypes.shape({
                displayName: React.PropTypes.string,
                profilePhotoUrl: React.PropTypes.string,
                userUrl: React.PropTypes.string
            }),
            side: React.PropTypes.string
        })
    },

    render () {
        const { openState } = this.state;
        const dropdownClass = `opinion-profile dropdown ${(openState ? 'dropdown-active' : '')}`;
        const trigger = (<a href={this.props.vote.voter.user_url}
                            className="dropdown-trigger"
                            onClick={this.handleClick}
                            done={this.close}
                            data-turbolinks="false">
            <img src={this.props.vote.voter.profile_photo_url}/>
        </a>);

        const dropdownContent = <OpinionContent close={this.close} {...this.props} />;

        return (<div tabIndex="1"
                     className={dropdownClass}
                     onMouseEnter={this.onMouseEnter}
                     onMouseLeave={this.onMouseLeave}>
            {trigger}
            <div className="reference-elem" style={{ visibility: 'hidden', overflow: 'hidden', 'pointerEvents': 'none', position: 'absolute' }}>{dropdownContent}</div>
            <ReactTransitionGroup transitionName="dropdown" transitionAppear={true} component="div">
                {openState && dropdownContent}
            </ReactTransitionGroup>
        </div>);

    }

});
window.SingleVote = SingleVote;

