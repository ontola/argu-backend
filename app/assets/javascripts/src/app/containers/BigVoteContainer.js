import React from 'react';
import { connect, Provider } from 'react-redux';
import { VoteButtons, VoteResults } from '../components/Vote';
import { IntlMixin } from 'react-intl';
import configureStore from '../stores/configureStore';
import { createVote } from '../actions/index';

/**
 * Component that displays current vote options.
 * Also reveals the results if the user has already voted.
 * This component is not pure.
 * @class
 * @exports BigVoteContainer
 * @see {@linkcode Vote.VoteButtons}
 * @see {@linkcode Vote.VoteResults}
 */
const BigVoteInnerContainer = React.createClass({
    mixins: [IntlMixin],

    propTypes: {
        createVote: React.PropTypes.func,
        currentVoteId: React.PropTypes.string,
        distribution: React.PropTypes.object,
        objectType: React.PropTypes.string,
        objectId: React.PropTypes.number,
        votes: React.PropTypes.object,
        percent: React.PropTypes.object
    },

    handleVote (side, event) {
        event.preventDefault();
        this.props.createVote(this.props.objectId, side);
    },

    render () {
        const { currentVoteId, percent, votes } = this.props;
        let voteResultsComponent;
        if (votes[currentVoteId] && votes[currentVoteId].side !== 'abstain') {
            voteResultsComponent = <VoteResults percent={percent} />;
        }
        const voteButtonsComponent = <VoteButtons onVote={this.handleVote}
                                                  vote={votes[currentVoteId]}
                                                  {...this.props} />;

        return (
            <div className="center motion-shr">
                {voteResultsComponent}
                {voteButtonsComponent}
            </div>
        );
    }
});

function mapStateToProps(state, ownProps) {
    return Object.assign({}, ownProps, state.votes);
}

const WrappedBigVoteInnerContainer = connect(mapStateToProps, {
    createVote
})(BigVoteInnerContainer);

export const BigVoteContainer = React.createClass({
    propTypes: {
        votes: React.PropTypes.object
    },
    
    render () {
        return (<Provider store={configureStore({ votes: { votes: { ...this.props.votes } } })}>
            <WrappedBigVoteInnerContainer {...this.props} {...this.state} />
        </Provider>);
    }
});

window.BigVoteContainer = BigVoteContainer;
