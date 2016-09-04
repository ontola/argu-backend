import fetch from 'isomorphic-fetch';
import { Promise } from 'es6-promise';
import { batchActions } from 'redux-batched-actions';

import DataStore from './utils/DataStore';
import { ARGU_API_URL_EXT } from '../config';

let dataStore;

const callApi = (endpoint) => {
  const fullUrl = ARGU_API_URL_EXT + endpoint;

  return fetch(fullUrl)
    .then(response =>
      response.json().then(json => ({ json, response }))
    ).then(({ json, response }) => {
      if (!response.ok) {
        return Promise.reject(json);
      }
      return Promise.resolve(json);
    });
};

const parseResult = (jsonData, emitRecord, next) => {
  const actions = [];
  if (jsonData.data.constructor === Array) {
    jsonData.data.forEach(entity => {
      actions.push(emitRecord(dataStore.formatEntity(entity)));
    });
  } else {
    actions.push(emitRecord(dataStore.formatEntity(jsonData.data)));
  }
  if (jsonData.included) {
    jsonData.included.forEach(entity => actions.push(emitRecord(dataStore.formatEntity(entity))));
  }

  next(batchActions(actions));
};

const middleware = () => next => action => {
  if (!action.payload) {
    return next(action);
  }

  if (!action.payload.apiAction) {
    return next(action);
  }

  const {
    id,
    endpoint,
  } = action.payload;

  const constructEndpoint = id ? `${endpoint}/${id}` : endpoint;

  const emitRecord = (record) => ({
    type: record.getIn(['apiDesc', 'actions', 'resource']),
    payload: {
      record,
    },
  });

  next({
    type: action.type,
    payload: {
      loading: true,
      id,
    },
  });

  return callApi(constructEndpoint)
    .then(jsonData => parseResult(jsonData, emitRecord, next))
    .catch(error => next({
      type: action.type,
      error: true,
      payload: {
        message: error.message || 'Something bad happened',
        id,
      },
    }));
};

export default models => {
  dataStore = new DataStore(models);
  return middleware;
};
