import Alert from '../components/Alert';
import { createMembership, MEMBERSHIP_SUCCESS } from '../actions';

export const notAUserFilter = _store => next => action => {
    if (!action.payload || action.payload.status !== 401) {
        return next(action);
    } else {
        const { type, error_id, session_url: sessionUrl } = action.payload.response;
        if (type === 'error' && error_id === 'NOT_A_USER') {
            window.location.href = sessionUrl;
        }
    }
};

export const notAMemberFilter = store => next => action => {
    if (!action.payload || action.payload.status !== 403) {
        return next(action);
    } else {
        const { type, error_id, membership_url: membershipUrl } = action.payload.response;
        if (type === 'error' && error_id === 'NOT_A_MEMBER') {
            return store
                .dispatch(createMembership(membershipUrl))
                .then(membershipAction => {
                    if (membershipAction.type === MEMBERSHIP_SUCCESS) {
                        return store.dispatch(action.meta.retryAction());
                    } else {
                        const message = 'Creating membership failed';
                        new Alert(message, 'alert', true);
                        throw (membershipAction);
                    }
                });
        }
    }
};

export const notModifiedFilter = _store => next => action => {
    if (!action.payload || action.payload.status !== 304) {
        return next(action);
    } else {
        action.type = action.type.replace('_FAILURE', '_SUCCESS');
        return next(action);
    }
};
