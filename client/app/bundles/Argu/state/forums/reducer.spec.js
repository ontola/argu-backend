
import chai, { assert } from 'chai';
import { Map } from 'immutable';
import chaiImmutable from 'chai-immutable';

import motions from './reducer';
import * as models from 'models';
import * as actions from '../action-types';

chai.use(chaiImmutable);

describe('Motions reducer', () => {
  it('should return the initial state', () => {
    const expectedState = new Map({
      items: new Map(),
      votes: new Map(),
    });

    assert.deepEqual(
      motions(undefined, {}),
      expectedState,
      'Initial state is not correct'
    );
  });

  it('should handle GET_MOTION', () => {
    const expectedResponse = new Map({
      items: new Map({
        14: new models.Motion({
          id: '14',
          loading: true,
        }),
      }),
      votes: new Map(),
    });

    assert.deepEqual(
      motions(undefined, {
        type: actions.GET_MOTION,
        payload: {
          apiAction: true,
          endpoint: 'motions',
          id: '14',
        },
      }),
      expectedResponse,
      'does not handle GET_MOTION very well'
    );
  });

  it('should handle SET_VOTE', () => {
    const expectedResponse = new Map({
      items: new Map(),
      votes: new Map({
        14: new models.Vote({
          id: '14',
          individual: true,
          value: 'pro',
        }),
      }),
    });

    assert.deepEqual(
      motions(undefined, {
        type: actions.SET_VOTE,
        payload: {
          apiAction: true,
          endpoint: 'votes',
          motionId: '14',
          side: 'pro',
        },
      }),
      expectedResponse,
      'does not handle SET_VOTE very well'
    );
  });
});
