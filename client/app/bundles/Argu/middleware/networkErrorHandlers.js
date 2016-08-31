import Alert from '../components/Alert';
import {
  createMembership,
  MEMBERSHIP_SUCCESS,
} from '../actions';

export const notAUserFilter = _store => next => action => {
  if (!action.payload || action.payload.status !== 401) {
    return next(action);
  }
  const { type, error_id: errorId, session_url: sessionUrl } = action.payload.response;
  if (type === 'error' && errorId === 'NOT_A_USER') {
    window.location.href = sessionUrl;
  }
  return next(action);
};

export const notAMemberFilter = store => next => action => {
  if (!action.payload || action.payload.status !== 403) {
    return next(action);
  }
  const { type, error_id: errorId, membership_url: membershipUrl } = action.payload.response;
  if (type === 'error' && errorId === 'NOT_A_MEMBER') {
    return store
      .dispatch(createMembership(membershipUrl))
      .then(membershipAction => {
        if (membershipAction.type === MEMBERSHIP_SUCCESS) {
          return store.dispatch(action.meta.retryAction());
        }
        const message = 'Creating membership failed';
        new Alert(message, 'alert', true);
        throw (membershipAction);
      });
  }
  return next(action);
};

export const notModifiedFilter = _store => next => action => {
  if (!action.payload || action.payload.status !== 304) {
    return next(action);
  }
  const newAction = action;
  newAction.type = action.type.replace('_FAILURE', '_SUCCESS');
  return next(newAction);
};
