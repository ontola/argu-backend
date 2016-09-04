import { applyMiddleware, createStore, compose } from 'redux';
import thunk from 'redux-thunk';
import { enableBatching } from 'redux-batched-actions';
import { combineReducers } from 'redux-immutable';
import { Map } from 'immutable';

// import argumentations from './argumentations/reducer';
import currentActors from './currentActors/reducer';
// import communication from './communication/reducer';
import forums from './forums/reducer';
import motions from './motions/reducer';
// import persons from './persons/reducer';
// import router from './router/reducer';
// import search from './search/reducer';
import votes from './votes/reducer';
// import votematch from './votematch/reducer';

import API from '../middleware/api';
import DataStore from '../middleware/utils/DataStore';
import * as models from '../records';

const rootReducer = combineReducers({
  // argumentations,
  'current-actors': currentActors,
  forums,
  // communication,
  motions,
  // persons,
  // router,
  // search,
  // votematch,
  votes,
});

function generateInitialState(initialState = undefined) {
  const datastore = new DataStore(Object.values(models));

  const finalState = new Map().withMutations(mutState => {
    initialState.data.forEach(entity => {
      const ent = datastore.formatEntity(entity);
      const type = ent.apiDesc.get("type");
      mutState.setIn([type, 'items', ent.id], ent);
    });
  });
  return finalState;
}

const configureStore = (preloadedState) => {
  const apiMiddleware = new API(Object.values(models));
  let middleware;

  if (process.env.NODE_ENV === 'production') {
    middleware = applyMiddleware(thunk, apiMiddleware);
  } else {
    middleware = compose(
      applyMiddleware(thunk, apiMiddleware),
      typeof window === 'object' &&
      typeof window.devToolsExtension !== 'undefined' ? window.devToolsExtension() : f => f
    );
  }

  const store = createStore(
    enableBatching(rootReducer),
    generateInitialState(preloadedState),
    middleware
  );

  return store;
};

export default configureStore;
