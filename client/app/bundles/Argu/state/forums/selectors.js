import { createSelector } from 'reselect';

export const getMotions = (state) => state.getIn(['motions', 'items']);

export const getMotionId = (state, props) => {
  if (props.params) {
    return props.params.motionId;
  }

  if (props.motionId) {
    return props.motionId;
  }

  return false;
};

export const getMotion = createSelector(
  [getMotions, getMotionId],
  (motions, id) => motions.get(id)
);

export const getMotionTitle = createSelector(
  [getMotions, getMotionId],
  (motions, id) => {
    if (motions.get(id) === undefined) {
      return '';
    }
    return motions.getIn([id, 'title']);
  }
);

export const getMotionArgIds = createSelector(
  [getMotions, getMotionId],
  (motions, id) => {
    if (motions.get(id) === undefined) {
      return '';
    }
    return motions.getIn([id, 'arguments']);
  }
);
