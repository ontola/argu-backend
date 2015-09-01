
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
            'use strict';
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

var _image = function (props) {
    if (props.image) {
        return <img src={props.image.url} alt={props.image.title} className={props.image.className} />;
    } else if (props.fa) {
        return <span className={['fa', props.fa].join(' ')} />;
    }
};

var _url = function (url, obj) {
    "use strict";
    if (typeof(url) === "string" && typeof(obj) === "object") {
        var res = decodeURIComponent(url).replace(/{{([^{}]+)}}/, function (match, p1) {
            return Object.resolve(p1, obj);
        });
        return res || decodeURIComponent(url);
    } else if (url !== null) {
        return decodeURIComponent(url);
    }
};

var _authenticityHeader = function (options) {
    "use strict";
    options = options || {};
    return Object.assign(options, {
        'X-CSRF-Token': getAuthenticityToken(),
        'X-Requested-With': 'XMLHttpRequest'
    });
};

var getAuthenticityToken = function () {
    return getMetaContent('csrf-token');
};

var getMetaContent = function (name) {
    let header = document.querySelector(`meta[name="${name}"]`);
    return header && header.content;
};

var getUserIdentityToken = function () {
    return {token: getMetaContent('user-identity-token')};
};

var jsonHeader = function (options) {
    options = options || {};
    return Object.assign(options, {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
    });
};

var _safeCredentials = function (options) {
    "use strict";
    options = options || {};
    return Object.assign(options, {
        credentials: 'include',
        mode: 'same-origin',
        headers: Object.assign((options['headers'] || {}), _authenticityHeader(), jsonHeader())
    });
};

var statusSuccess = function (response) {
    if (response.status >= 200 && response.status < 300) {
        return Promise.resolve(response);
    } else {
        return Promise.reject(response);
    }
};

var tryLogin = function (response) {
    "use strict";
    if (response.status == 401) {
        return Promise.resolve(window.alert('You should login.'));
    } else {
        return Promise.reject(new Error('unknown status code'));
    }
};

var _userIdentityToken = function (options) {
    "use strict";
    options = options || {};
    return Object.assign(options, {
      body: JSON.stringify(Object.assign((options['body'] || {}), getUserIdentityToken()))
    })
};

var json = function (response) {
    if (response.status !== 204) {
        return response.json();
    } else {
        return Promise.resolve();
    }
};

if (typeof module !== 'undefined' && module.exports) {
    module.exports = _image;
    module.exports = _url;
    module.exports = _authenticityHeader;
    module.exports = _safeCredentials;
    module.exports = statusSuccess;
    module.exports = tryLogin;
    module.exports = json;
    module.exports = ScrollLockMixin;
}
