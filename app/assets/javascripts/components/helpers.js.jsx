

var _image = function (props) {
    if (props.image) {
        return <img src={props.image.url} alt={props.image.title} className={props.image.className} />;
    } else if (props.fa) {
        return <span className={['fa', props.fa].join(' ')} />;
    }
};

if (typeof module !== 'undefined' && module.exports) {
    module.exports = _image;
    module.exports = ScrollLockMixin;
}