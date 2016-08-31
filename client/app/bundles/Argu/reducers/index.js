import { combineReducers } from 'redux';
import { reducer as form } from 'redux-form';

import motions from './motions';
import navbarApp from './navbarApp';
import notifications from './notifications';
import profiles from './profiles';
import session from './session';
import votes from './votes';

const rootReducer = combineReducers({
  form,
  motions,
  navbarApp,
  notifications,
  profiles,
  session,
  votes,
});

export default rootReducer;
