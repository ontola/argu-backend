

var _image = function (props) {
    if (props.image) {
        return <img src={props.image.url} alt={props.image.title} className={props.image.className} />;
    } else if (props.fa) {
        return <span className={['fa', props.fa].join(' ')} />;
    }
};

Object.resolve = function(path, obj) {
    return [obj || self].concat(path.split('.')).reduce(function(prev, curr) {
        console.log(prev, curr);
        return prev && prev[curr]
    });
};

var _url = function (url, obj) {
    "use strict";
    if (typeof(obj) === "object") {
        var res = decodeURIComponent(url).replace(/{{([^{}]+)}}/g, function (match, p1, p2, p3, offset, string) {
            return Object.resolve(p1, obj);
        });
        return res || decodeURIComponent(url);
    } else {
        return decodeURIComponent(url);
    }
};

if (typeof module !== 'undefined' && module.exports) {
    module.exports = _image;
    module.exports = _url;
    module.exports = ScrollLockMixin;
}