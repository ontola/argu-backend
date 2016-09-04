import React, { PropTypes } from 'react';
import { Box } from 'components';

const defaultButtons = (id, vote, nextMotion) => {
  const btnActionFunc = nextMotion || vote;
  const btnAction = (side) => btnActionFunc({
    motionId: id,
    side,
  });

  return [{
    icon: 'thumbs-up',
    label: 'Ik ben voor',
    side: 'pro',
    action: () => {
      btnAction('pro');
    },
  }, {
    icon: 'pause',
    label: 'Neutraal',
    side: 'neutral',
    action: () => {
      btnAction('neutral');
    },
  }, {
    icon: 'thumbs-down',
    label: 'Ik ben tegen',
    side: 'con',
    action: () => {
      btnAction('con');
    },
  }];
};

const propTypes = {
  id: PropTypes.string,
  onVoteAction: PropTypes.func,
  onNextMotion: PropTypes.func,
};

const MotionShow = (props) => (
  <Box
    {...props}
    boxActions={defaultButtons(props.id, props.onVoteAction, props.onNextMotion)}
    showMeta
    showLink
    headingSize="2"
  />
);

MotionShow.propTypes = propTypes;

export default MotionShow;
