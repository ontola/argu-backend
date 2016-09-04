import chai, { assert } from 'chai';
import { Map } from 'immutable';
import chaiImmutable from 'chai-immutable';

import persons from './reducer';
import * as models from 'models';
import * as actions from '../action-types';

chai.use(chaiImmutable);

describe('Persons reducer', () => {
  it('should return the initial state', () => {
    const expectedState = new Map({
      items: new Map(),
    });

    assert.deepEqual(
      persons(undefined, {}),
      expectedState,
      'Initial state is not correct'
    );
  });

  it('should handle GET_PERSON', () => {
    const expectedResponse = new Map({
      items: new Map({
        14: new models.Person({
          id: '14',
        }),
      }),
    });

    assert.deepEqual(
      persons(undefined, {
        type: actions.GET_PERSON,
        payload: {
          apiAction: true,
          endpoint: 'persons',
          id: '14',
        },
      }),
      expectedResponse,
      'does not handle GET_PERSON very well'
    );
  });
});
