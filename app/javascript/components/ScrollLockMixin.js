export const ScrollLockMixin = {
    cancelScrollEvent (e) {
        e.stopImmediatePropagation();
        e.preventDefault();
        e.returnValue = false;
        return false;
    },

    addScrollEventListener (elem, handler) {
        elem.addEventListener('wheel', handler, false);
    },

    removeScrollEventListener (elem, handler) {
        elem.removeEventListener('wheel', handler, false);
    },

    scrollLock (elem) {
        elem = elem || ReactDOM.findDOMNode(this);
        this.scrollElem = elem;
        ScrollLockMixin.addScrollEventListener(elem, this.onScrollHandler);
    },

    scrollRelease (elem) {
        elem = elem || this.scrollElem;
        ScrollLockMixin.removeScrollEventListener(elem, this.onScrollHandler);
    },

    onScrollHandler (e) {
        const elem = this.scrollElem;
        const scrollTop = elem.scrollTop;
        const scrollHeight = elem.scrollHeight;
        const height = elem.clientHeight;
        const wheelDelta = e.deltaY;
        const isDeltaPositive = wheelDelta > 0;

        if (isDeltaPositive && wheelDelta > scrollHeight - height - scrollTop) {
            elem.scrollTop = scrollHeight;
            return ScrollLockMixin.cancelScrollEvent(e);
        }
        else if (!isDeltaPositive && -wheelDelta > scrollTop) {
            elem.scrollTop = 0;
            return ScrollLockMixin.cancelScrollEvent(e);
        }
    }
};

export default ScrollLockMixin;
