import React from 'react';
import { connect, Provider } from 'react-redux';
import { VoteButtons } from '../components/Vote';
import { IntlMixin } from 'react-intl';
import configureStore from '../stores/configureStore';
import { createVote } from '../actions/index';

/**
 * Component that displays current vote options.
 * This component is not pure.
 * @class
 * @exports SmallVoteContainer
 * @see {@linkcode Vote.VoteButtons}
 */
const SmallVoteInnerContainer = React.createClass({
    mixins: [IntlMixin],

    propTypes: {
        createVote: React.PropTypes.func,
        currentVoteId: React.PropTypes.string,
        distribution: React.PropTypes.object,
        objectType: React.PropTypes.string,
        objectId: React.PropTypes.number,
        votes: React.PropTypes.object
    },

    handleVote (side, event) {
        event.preventDefault();
        this.props.createVote(this.props.objectId, side);
    },

    render () {
        const { currentVoteId, votes } = this.props;
        const voteButtonsComponent = <VoteButtons onVote={this.handleVote}
                                                  vote={votes[currentVoteId]}
                                                  {...this.props} />;

        return (
            <div className="center motion-shr">
                {voteButtonsComponent}
            </div>
        );
    }
});

function mapStateToProps(state, ownProps) {
    return Object.assign({}, ownProps, state.votes);
}

const WrappedSmallVoteInnerContainer = connect(mapStateToProps, {
    createVote
})(SmallVoteInnerContainer);

export const SmallVoteContainer = React.createClass({
    propTypes: {
        votes: React.PropTypes.object
    },
    
    render () {
        return (<Provider store={configureStore({ votes: { votes: { ...this.props.votes } } })}>
            <WrappedSmallVoteInnerContainer {...this.props} {...this.state} />
        </Provider>);
    }
});

window.SmallVoteContainer = SmallVoteContainer;
