import { CALL_API } from 'redux-api-middleware';
import { _authenticityHeader, jsonHeader } from '../lib/helpers';

export const CLOSE_OPINION_FORM = 'CLOSE_OPINION_FORM';

export const VOTE_REQUEST = 'VOTE_REQUEST';
export const VOTE_SUCCESS = 'VOTE_SUCCESS';
export const VOTE_FAILURE = 'VOTE_FAILURE';

export const MEMBERSHIP_REQUEST = 'MEMBERSHIP_REQUEST';
export const MEMBERSHIP_SUCCESS = 'MEMBERSHIP_SUCCESS';
export const MEMBERSHIP_FAILURE = 'MEMBERSHIP_FAILURE';

export const OPINION_REQUEST = 'OPINION_REQUEST';
export const OPINION_SUCCESS = 'OPINION_SUCCESS';
export const OPINION_FAILURE = 'OPINION_FAILURE';

export const closeOpinionForm = () => ({
    type: CLOSE_OPINION_FORM
});

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

export const createOpinion = (id, side) => ({
    [CALL_API]: {
        endpoint: `/m/${id}/opinions.json`,
        method: 'POST',
        types: [
            OPINION_REQUEST,
            OPINION_SUCCESS,
            {
                type: OPINION_FAILURE,
                meta: {
                    retryAction: createOpinion.bind(null, id, side)
                }
            }
        ],
        credentials: 'same-origin',
        headers: jsonHeader(_authenticityHeader())
    }
});
