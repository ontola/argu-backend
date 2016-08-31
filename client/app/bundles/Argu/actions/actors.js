import { CALL_API } from 'redux-api-middleware';
import { authenticityHeader, jsonHeader } from '../lib/helpers';

export const ACTOR_UPDATE_REQUEST = 'ACTOR_UPDATE_REQUEST';
export const ACTOR_UPDATE_SUCCESS = 'ACTOR_UPDATE_SUCCESS';
export const ACTOR_UPDATE_FAILURE = 'ACTOR_UPDATE_FAILURE';

export const actorUpdate = actor => ({
  [CALL_API]: {
    endpoint: `/actors?na=${actor}`,
    method: 'PUT',
    types: [
      ACTOR_UPDATE_REQUEST,
      ACTOR_UPDATE_SUCCESS,
      ACTOR_UPDATE_FAILURE,
    ],
    credentials: 'same-origin',
    headers: jsonHeader(authenticityHeader()),
  },
});

