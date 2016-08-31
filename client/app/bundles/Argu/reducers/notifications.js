import * as ActionTypes from '../actions';
const initialState = [];

export default function notifications(state = initialState, action) {
  switch (action.type) {
    case ActionTypes.NOTIFICATIONS_SUCCESS:
      return Object.assign(
            {},
            state,
            Object.assign(
                {},
                action.payload.notifications,
              {
                nextPage: parseInt(action.payload.notifications.page, 10) + 1,
                notifications: state
                  .notifications
                  .concat(action.payload.notifications.notifications),
              }
            ));
    default:
      return state;
  }
}
