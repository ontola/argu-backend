import { assert } from 'chai';
import * as models from 'models';
import * as actions from 'state/action-types';

const SPECIFIC_PERSON_ID = 14;

describe('Persons actions', () => {
  it('should have an action to get a specific Person', () => {
    const expectedAction = {
      type: actions.GET_PERSON,
      payload: {
        apiAction: true,
        endpoint: 'persons',
        id: SPECIFIC_PERSON_ID,
      },
    };

    assert.deepEqual(
      models.Person.fetch(SPECIFIC_PERSON_ID),
      expectedAction,
      'Action is not formatted correctly');
  });

  it('should have an action to get all Persons', () => {
    const expectedAction = {
      type: actions.GET_PERSONS,
      payload: {
        apiAction: true,
        endpoint: 'persons',
      },
    };

    assert.deepEqual(
      models.Person.index(),
      expectedAction,
      'Action is not formatted correctly');
  });
});
