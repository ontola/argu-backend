import { compose, createStore, applyMiddleware } from 'redux';
import { apiMiddleware } from 'redux-api-middleware';

import DataStore from '../middleware/utils/DataStore';
import * as models from '../records';
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
  const datastore = new DataStore(Object.values(models));
  const state = {};
  initialState.data.forEach(entity => {
    const ent = datastore.formatEntity(entity);
    if(typeof(state[ent.apiDesc.get("type")]) === "undefined") {
      state[ent.apiDesc.get("type")] = []
    }
    state[ent.apiDesc.get("type")].push(ent)
  });
  initialState = state;
  console.log('initialState', initialState);
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
