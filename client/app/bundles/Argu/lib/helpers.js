import React from 'react';

/**
 * @module Helpers
 */


Object.resolve = function resolve(path, obj) {
  return [obj || global]
        .concat(path.split('.'))
        .reduce((prev, curr) => prev && prev[curr]);
};

if (!Object.assign) {
  Object.defineProperty(Object, 'assign', {
    enumerable: false,
    configurable: true,
    writable: true,
    value(target, ...args) {
      if (target === undefined || target === null) {
        throw new TypeError('Cannot convert first argument to object');
      }

      const to = Object(target);
      for (let i = 1; i < args.length; i++) {
        let nextSource = args[i];
        if (nextSource === undefined || nextSource === null) {
          continue;
        }
        nextSource = Object(nextSource);

        const keysArray = Object.keys(Object(nextSource));
        for (let nextIndex = 0, len = keysArray.length; nextIndex < len; nextIndex++) {
          const nextKey = keysArray[nextIndex];
          const desc = Object.getOwnPropertyDescriptor(nextSource, nextKey);
          if (desc !== undefined && desc.enumerable) {
            to[nextKey] = nextSource[nextKey];
          }
        }
      }
      return to;
    },
  });
}

/**
 * @param {Object} props The props of the imageable element.
 * @returns {ReactElement|undefined} Proper image element.
 */
export function image({ image: imgObj, fa }) {
  if (imgObj) {
    return <img src={imgObj.url} alt={imgObj.title} className={imgObj.className} />;
  } else if (fa) {
    return <span className={['fa', fa].join(' ')} />;
  }
  return undefined;
}

image.propTypes = {
  fa: React.PropTypes.string,
  image: React.PropTypes.object,
};

export function getMetaContent(name) {
  const header = document.querySelector(`meta[name="${name}"]`);
  return header && header.content;
}

export function getAuthenticityToken() {
  return getMetaContent('csrf-token');
}

export function authenticityHeader(options = {}) {
  return Object.assign(options, {
    'X-CSRF-Token': getAuthenticityToken(),
    'X-Requested-With': 'XMLHttpRequest',
  });
}

export function errorMessageForStatus(status) {
  if (status === 401) {
    return {
      type: 'alert',
      severity: 'error',
      i18nString: 'errors.status.401',
      fallback: 'Je moet ingelogd zijn voor deze actie.',
    };
  } else if (status === 404) {
    return {
      type: 'alert',
      severity: 'error',
      i18nString: 'errors.status.404',
      fallback: 'Het item is niet gevonden, probeer de pagina te verversen.',
    };
  } else if (status === 429) {
    return {
      type: 'alert',
      severity: 'error',
      i18nString: 'errors.status.429',
      fallback: 'Je maakt te veel verzoeken, probeer het over halve minuut nog eens.',
    };
  } else if (status === 500) {
    return {
      type: 'alert',
      severity: 'error',
      i18nString: 'errors.status.500',
      fallback: 'Er ging iets aan onze kant fout, probeer het later nog eens.',
    };
  } else if (status === 0) {
    return {
      type: 'none',
      severity: '',
      i18nString: undefined,
      fallback: '',
    };
  }
  return {
    type: 'none',
    severity: '',
    i18nString: undefined,
    fallback: undefined,
  };
}

export function getUserIdentityToken() {
  return { token: getMetaContent('user-identity-token') };
}


/**
 * For use with window.fetch
 * @param {Object} options Object to be merged with jsonHeader options.
 * @returns {Object} The merged object.
 */
export function jsonHeader(options = {}) {
  return Object.assign(options, {
    Accept: 'application/json',
    'Content-Type': 'application/json',
  });
}

/**
 * Lets fetch include credentials in the request. This includes cookies and other possibly sensitive
 * data.
 * Note: Never use for requests across (untrusted) domains.
 * @param {Object} options Object to be merged with safeCredentials options.
 * @returns {Object} The merged object.
 */
export function safeCredentials(options = {}) {
  return Object.assign(options, {
    credentials: 'include',
    mode: 'same-origin',
    headers: Object.assign((options.headers || {}), authenticityHeader(), jsonHeader()),
  });
}

export function statusSuccess(response) {
  if (response.status >= 200 && response.status < 300 || response.status === 304) {
    return Promise.resolve(response);
  }
  return Promise.reject(response);
}

export function tryLogin(response) {
  if (response.status === 401) {
    return Promise.resolve(window.alert(errorMessageForStatus(response.status).fallback));
  }
  return Promise.reject(response);
}

export function userIdentityToken(options = {}) {
  return Object.assign(options, {
    body: JSON.stringify(Object.assign((options.body || {}), getUserIdentityToken())),
  });
}

export function json(response) {
  if (typeof response !== 'undefined' && response.status !== 204 && response.status !== 304) {
    return response.json();
  }
  return Promise.resolve();
}

