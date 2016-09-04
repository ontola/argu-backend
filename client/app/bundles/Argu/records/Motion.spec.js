import { assert } from 'chai';
import * as models from 'models';
import * as actions from 'state/action-types';

const SPECIFIC_MOTION_ID = 14;

describe('Motion actions', () => {
  it('should have an action to get a specific motion', () => {
    const expectedAction = {
      type: actions.GET_MOTION,
      payload: {
        apiAction: true,
        endpoint: 'motions',
        id: SPECIFIC_MOTION_ID,
      },
    };

    assert.deepEqual(
      models.Motion.fetch(SPECIFIC_MOTION_ID),
      expectedAction,
      'Action is not formatted correctly');
  });

  it('should have an action to get all motions', () => {
    const expectedAction = {
      type: actions.GET_MOTIONS,
      payload: {
        apiAction: true,
        endpoint: 'motions',
      },
    };

    assert.deepEqual(
      models.Motion.index(),
      expectedAction,
      'Action is not formatted correctly');
  });
});
