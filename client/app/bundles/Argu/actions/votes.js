import { CALL_API } from 'redux-api-middleware';
import { authenticityHeader, jsonHeader } from '../lib/helpers';

export const VOTE_CREATE_REQUEST = 'VOTE_CREATE_REQUEST';
export const VOTE_CREATE_SUCCESS = 'VOTE_CREATE_SUCCESS';
export const VOTE_CREATE_FAILURE = 'VOTE_CREATE_FAILURE';

export const voteCreate = (type, id, side) => ({
  [CALL_API]: {
    endpoint: `/${type[0]}/${id}/v/${side}.json`,
    method: 'POST',
    types: [
      VOTE_CREATE_REQUEST,
      VOTE_CREATE_SUCCESS,
      {
        type: VOTE_CREATE_FAILURE,
        meta: {
          retryAction: voteCreate.bind(null, type, id, side),
        },
      },
    ],
    credentials: 'same-origin',
    headers: jsonHeader(authenticityHeader()),
  },
});
