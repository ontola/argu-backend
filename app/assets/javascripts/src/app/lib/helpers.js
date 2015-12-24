import React from 'react';
React; // For ESLint, jsx compiles to React.createElement, so React must be imported
import Intl from 'intl';
Intl; // For ESLint
import { IntlMixin } from 'react-intl';

/**
 * @module Helpers
 */


Object.resolve = function(path, obj) {
    return [obj || self].concat(path.split('.')).reduce(function(prev, curr) {
        return prev && prev[curr]
    });
};

if (!Object.assign) {
    Object.defineProperty(Object, 'assign', {
        enumerable: false,
        configurable: true,
        writable: true,
        value: function(target) {
            if (target === undefined || target === null) {
                throw new TypeError('Cannot convert first argument to object');
            }

            var to = Object(target);
            for (var i = 1; i < arguments.length; i++) {
                var nextSource = arguments[i];
                if (nextSource === undefined || nextSource === null) {
                    continue;
                }
                nextSource = Object(nextSource);

                var keysArray = Object.keys(Object(nextSource));
                for (var nextIndex = 0, len = keysArray.length; nextIndex < len; nextIndex++) {
                    var nextKey = keysArray[nextIndex];
                    var desc = Object.getOwnPropertyDescriptor(nextSource, nextKey);
                    if (desc !== undefined && desc.enumerable) {
                        to[nextKey] = nextSource[nextKey];
                    }
                }
            }
            return to;
        }
    });
}

export function image (props) {
    if (props.image) {
        return <img src={props.image.url} alt={props.image.title} className={props.image.className} />;
    } else if (props.fa) {
        return <span className={['fa', props.fa].join(' ')} />;
    }
}

export function _url (url, obj) {
    if (typeof url === 'string' && typeof obj === 'object') {
        var res = decodeURIComponent(url).replace(/{{([^{}]+)}}/, function (match, p1) {
            return Object.resolve(p1, obj);
        });
        return res || decodeURIComponent(url);
    } else if (url !== null) {
        return decodeURIComponent(url);
    }
}

export function _authenticityHeader (options) {
    options = options || {};
    return Object.assign(options, {
        'X-CSRF-Token': getAuthenticityToken(),
        'X-Requested-With': 'XMLHttpRequest'
    });
}

export function errorMessageForStatus(status) {
    if (status === 401) {
        return {
            "type": "alert",
            "severity": "error",
            "i18nString": "errors.status.401",
            "fallback": "Je moet ingelogd zijn voor deze actie."
        };
    } else if (status === 404) {
        return {
            "type": "alert",
            "severity": "error",
            "i18nString": "errors.status.404",
            "fallback": "Het item is niet gevonden, probeer de pagina te verversen."
        };
    } else if (status === 429) {
        return {
            "type": "alert",
            "severity": "error",
            "i18nString": "errors.status.429",
            "fallback": "Je maakt te veel verzoeken, probeer het over halve minuut nog eens."
        };
    } else if (status === 500) {
        return {
            "type": "alert",
            "severity": "error",
            "i18nString": "errors.status.500",
            "fallback": "Er ging iets aan onze kant fout, probeer het later nog eens."
        };
    } else if (status === 0) {
        return {
            "type": "none",
            "severity": "",
            "i18nString": undefined,
            "fallback": ""
        };
    } else {
        return {
            "type": "none",
            "severity": "",
            "i18nString": undefined,
            "fallback": undefined
        };
    }
}

export function getAuthenticityToken () {
    return getMetaContent('csrf-token');
}

export function getMetaContent (name) {
    let header = document.querySelector(`meta[name="${name}"]`);
    return header && header.content;
}

export function getUserIdentityToken () {
    return {token: getMetaContent('user-identity-token')};
}


/**
 * For use with window.fetch
 */
export function jsonHeader (options) {
    options = options || {};
    return Object.assign(options, {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
    });
}

/**
 * Lets fetch include credentials in the request. This includes cookies and other possibly sensitive data.
 * Note: Never use for requests across (untrusted) domains.
 */
export function safeCredentials (options) {
    options = options || {};
    return Object.assign(options, {
        credentials: 'include',
        mode: 'same-origin',
        headers: Object.assign((options['headers'] || {}), _authenticityHeader(), jsonHeader())
    });
}

export function statusSuccess (response) {
    if (response.status >= 200 && response.status < 300 || response.status === 304) {
        return Promise.resolve(response);
    } else {
        return Promise.reject(response);
    }
}

export function tryLogin (response) {
    if (response.status === 401) {
        return Promise.resolve(window.alert(errorMessageForStatus(response.status).fallback));
    } else {
        return Promise.reject(response);
    }
}

export function userIdentityToken (options) {
    options = options || {};
    return Object.assign(options, {
        body: JSON.stringify(Object.assign((options['body'] || {}), getUserIdentityToken()))
    })
}

export function json (response) {
    if (typeof response !== 'undefined' && response.status !== 204 && response.status !== 304) {
        return response.json();
    } else {
        return Promise.resolve();
    }
}

