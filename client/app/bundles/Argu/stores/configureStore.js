import { compose, createStore, applyMiddleware } from 'redux';
import { apiMiddleware } from 'redux-api-middleware';

import {
  notAMemberFilter,
  notAUserFilter,
  notModifiedFilter,
} from '../middleware/networkErrorHandlers';
import rootReducer from '../reducers';

function reduxDevTools() {
  return typeof (window) !== 'undefined' && typeof window.devToolsExtension !== 'undefined'
        ? window.devToolsExtension()
        : f => f;
}

export default function configureStore(initialState) {
  const store = createStore(
        rootReducer,
        initialState,
        compose(
            applyMiddleware(apiMiddleware, notModifiedFilter, notAUserFilter, notAMemberFilter),
            reduxDevTools()
        )
    );
  return store;
}
