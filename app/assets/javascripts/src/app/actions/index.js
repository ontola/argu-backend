import { CALL_API } from 'redux-api-middleware';
import { _authenticityHeader, jsonHeader } from '../lib/helpers';

export const VOTE_REQUEST = 'VOTE_REQUEST';
export const VOTE_SUCCESS = 'VOTE_SUCCESS';
export const VOTE_FAILURE = 'VOTE_FAILURE';

export const MEMBERSHIP_REQUEST = 'MEMBERSHIP_REQUEST';
export const MEMBERSHIP_SUCCESS = 'MEMBERSHIP_SUCCESS';
export const MEMBERSHIP_FAILURE = 'MEMBERSHIP_FAILURE';

export const createVote = (id, side) => ({
    [CALL_API]: {
        endpoint: `/m/${id}/v/${side}.json`,
        method: 'POST',
        types: [
            VOTE_REQUEST,
            VOTE_SUCCESS,
            {
                type: VOTE_FAILURE,
                meta: {
                    retryAction: createVote.bind(null, id, side)
                }
            }
        ],
        credentials: 'same-origin',
        headers: jsonHeader(_authenticityHeader())
    }
});

export const createMembership = membershipUrl => ({
    [CALL_API]: {
        endpoint: membershipUrl,
        method: 'POST',
        types: [
            MEMBERSHIP_REQUEST,
            MEMBERSHIP_SUCCESS,
            MEMBERSHIP_FAILURE
        ],
        credentials: 'same-origin',
        headers: jsonHeader(_authenticityHeader())
    }
});
