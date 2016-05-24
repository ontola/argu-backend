import { createStore, applyMiddleware, compose } from 'redux';
import { apiMiddleware } from 'redux-api-middleware';
import { notAMemberFilter, notAUserFilter, notModifiedFilter } from '../middleware/networkErrorsHandlers';
import rootReducer from '../reducers';

export default function configureStore(initialState) {
    return createStore(rootReducer, initialState, compose(
        applyMiddleware(apiMiddleware, notModifiedFilter, notAUserFilter, notAMemberFilter),
        window.devToolsExtension ? window.devToolsExtension() : f => f
    ))
}
