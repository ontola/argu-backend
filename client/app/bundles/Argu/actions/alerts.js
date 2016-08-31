export const CREATE_ALERT = 'CREATE_ALERT';


export const createAlert = alert => ({
  type: CREATE_ALERT,
  payload: alert,
});

