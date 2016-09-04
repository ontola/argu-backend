
import React, { Component, PropTypes } from 'react';
import { connect } from 'react-redux';

import { MotionShow } from 'components';
import Motion from 'models/Motion';
import { getMotion } from 'state/motions/selectors';
import { getVoteByMotionId } from 'state/votes/selectors';
import { voteAction } from 'state/votes/actions';
// import { voteMatchNext } from 'state/votematch/actions';

const propTypes = {
  creator: PropTypes.object,
  data: PropTypes.instanceOf(Motion),
  loadMotion: PropTypes.func.isRequired,
  motionId: PropTypes.string.isRequired,
  nextMotion: PropTypes.func.isRequired,
  renderItem: PropTypes.func.isRequired,
  showArguments: PropTypes.bool,
  vote: PropTypes.func.isRequired,
  voteData: PropTypes.string,
};

const defaultProps = {
  renderItem: MotionShow,
  showArguments: false,
};

class MotionContainer extends Component {
  componentWillMount() {
    const { data, loadMotion, motionId } = this.props;

    if (data === undefined) {
      loadMotion(motionId);
    }
  }

  render() {
    const { data, nextMotion, renderItem, vote, voteData } = this.props;
    const RenderComponent = renderItem;

    if (!data) {
      return false;
    }

    return (
      <RenderComponent
        author={data.creator}
        children={data.text}
        date={data.createdAt}
        id={data.id}
        link={`/motions/${data.id}`}
        onVoteAction={vote}
        onNextMotion={nextMotion}
        title={data.title}
        type={data.classification}
        voteData={voteData}
      />
    );
  }
}

MotionContainer.propTypes = propTypes;
MotionContainer.defaultProps = defaultProps;

export default connect(
  (state, ownProps) => ({
    data: getMotion(state, ownProps),
    voteData: getVoteByMotionId(state, ownProps),
  }),
  (dispatch) => ({
    loadMotion: (id) => dispatch(Motion.fetch(id)),
    nextMotion: (data) => dispatch(voteMatchNext(data)),
    vote: (data) => dispatch(voteAction(data)),
  })
)(MotionContainer);
