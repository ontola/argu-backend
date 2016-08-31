import { CALL_API } from 'redux-api-middleware';
import { authenticityHeader, jsonHeader } from '../lib/helpers';

export const MEMBERSHIP_REQUEST = 'MEMBERSHIP_REQUEST';
export const MEMBERSHIP_SUCCESS = 'MEMBERSHIP_SUCCESS';
export const MEMBERSHIP_FAILURE = 'MEMBERSHIP_FAILURE';

export const createMembership = membershipUrl => ({
  [CALL_API]: {
    endpoint: membershipUrl,
    method: 'POST',
    types: [
      MEMBERSHIP_REQUEST,
      MEMBERSHIP_SUCCESS,
      MEMBERSHIP_FAILURE,
    ],
    credentials: 'same-origin',
    headers: jsonHeader(authenticityHeader()),
  },
});
