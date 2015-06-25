
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

var _authenticityToken = function () {
    "use strict";
    return document.querySelector('meta[name="csrf-token"]').content;
};

var _authenticityHeader = function (options) {
    "use strict";
    options = options || {};
    return Object.assign(options, {
        "X-CSRF-Token": _authenticityToken(),
        "X-Requested-With": "XMLHttpRequest"
    });
};

var _safeCredentials = function (options) {
    "use strict";
    options = options || {};
    return Object.assign(options, {
        credentials: 'include',
        mode: 'same-origin',
        headers: Object.assign((options['headers'] || {}), _authenticityHeader())
    });
};

var status = function (response) {
    if (response.status >= 200 && response.status < 300) {
        return Promise.resolve(response);
    } else {
        return Promise.reject(new Error(response.statusText));
    }
};

var json = function (response) {
    return response.json();
};

if (typeof module !== 'undefined' && module.exports) {
    module.exports = _image;
    module.exports = _url;
    module.exports = _authenticityHeader;
    module.exports = _safeCredentials;
    module.exports = status;
    module.exports = json;
    module.exports = ScrollLockMixin;
}
