import { createStore, applyMiddleware } from 'redux';
import { apiMiddleware } from 'redux-api-middleware';
import rootReducer from '../reducers';

const createMiddlewareEnabledStore = applyMiddleware(apiMiddleware)(createStore);

export default function configureStore(initialState) {
    return createMiddlewareEnabledStore(rootReducer, initialState)
}
