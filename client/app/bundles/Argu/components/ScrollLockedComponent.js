import { Component } from 'react';
import ReactDOM from 'react-dom';


class ScrollLockedComponent extends Component {
  onScrollHandler(e) {
    const elem = ReactDOM.findDOMNode(e.currentTarget);
    const scrollTop = elem.scrollTop;
    const scrollHeight = elem.scrollHeight;
    const height = elem.clientHeight;
    const wheelDelta = e.deltaY;
    const isDeltaPositive = wheelDelta > 0;

    if (isDeltaPositive && wheelDelta > scrollHeight - height - scrollTop) {
      elem.scrollTop = scrollHeight;
      return this.cancelScrollEvent(e);
    } else if (!isDeltaPositive && -wheelDelta > scrollTop) {
      elem.scrollTop = 0;
      return this.cancelScrollEvent(e);
    }
    return true;
  }

  cancelScrollEvent(e) {
    e.stopPropagation();
    e.preventDefault();
    return false;
  }
}

export default ScrollLockedComponent;
