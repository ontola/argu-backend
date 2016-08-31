import { CALL_API } from 'redux-api-middleware';
import { authenticityHeader, jsonHeader } from '../lib/helpers';

export const NOTIFICATIONS_REQUEST = 'NOTIFICATIONS_REQUEST';
export const NOTIFICATIONS_SUCCESS = 'NOTIFICATIONS_SUCCESS';
export const NOTIFICATIONS_FAILURE = 'NOTIFICATIONS_FAILURE';

export const indexNotifications = (page = 1) => ({
  [CALL_API]: {
    endpoint: `/n.json?page=${page}`,
    method: 'GET',
    types: [
      NOTIFICATIONS_REQUEST,
      NOTIFICATIONS_SUCCESS,
      NOTIFICATIONS_FAILURE,
    ],
    credentials: 'same-origin',
    headers: jsonHeader(authenticityHeader()),
  },
});
