import { Map, Record } from 'immutable';
import { authenticityHeader, jsonHeader } from '../../lib/helpers';

export const APIDesc = Record({
  actions: new Map(),
  endpoint: '',
  type: '',
});

export const apiModelGenerator = (properties, apiDesc) => {
  const superClass = Record(Object.assign(
    {},
    { apiDesc },
    properties
  ));

  const APIActionClass = class APIAction extends superClass {
    fetch() {
      this.fetch(this.get('id'));
    }

    index() {
      this.index();
    }
  };

  APIActionClass.create = (data) => ({
    type: apiDesc.get('actions').get('create'),
    payload: {
      fetchOptions: {
        method: 'POST',
        credentials: 'same-origin',
        headers: jsonHeader(authenticityHeader()),
        body: JSON.stringify({ data: data }),
      },
      apiAction: true,
      endpoint: apiDesc.get('endpoint'),
    },
  });

  APIActionClass.fetch = (id) => ({
    type: apiDesc.get('actions').get('resource'),
    payload: {
      apiAction: true,
      endpoint: apiDesc.get('endpoint'),
      id,
    },
  });

  APIActionClass.index = () => ({
    type: apiDesc.get('actions').get('collection'),
    payload: {
      apiAction: true,
      endpoint: apiDesc.get('endpoint'),
    },
  });

  return APIActionClass;
};
