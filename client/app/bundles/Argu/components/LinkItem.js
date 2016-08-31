import React, { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom';
import { image } from '../lib/helpers';

const propTypes = {
  className: PropTypes.string,
  data: PropTypes.shape({
    method: PropTypes.string,
    confirm: PropTypes.string,
    remote: PropTypes.string,
    turbolinks: PropTypes.string,
    'sort-value': PropTypes.string,
    'filter-value': PropTypes.string,
    'display-setting': PropTypes.string,
  }),
  divider: PropTypes.func,
  done: PropTypes.func,
  fa: PropTypes.string,
  image: PropTypes.object,
  target: PropTypes.string,
  title: PropTypes.string,
  type: PropTypes.string,
  url: PropTypes.string,
};

class LinkItem extends Component {
  handleMouseDown() {
    // Fixes an issue where firefox bubbles events instead of capturing them
    // See: https://github.com/facebook/react/issues/2011
    const dataMethod = ReactDOM.findDOMNode(this).getAttribute('data-method');
    if (dataMethod !== 'post' && dataMethod !== 'put' &&
      dataMethod !== 'patch' && dataMethod !== 'delete') {
      ReactDOM.findDOMNode(this).getElementsByTagName('a')[0].click();
      this.props.done();
    }
  }

  render() {
    const {
      className,
      data,
      fa,
      target,
      title,
      type,
      url,
    } = this.props;

    let divider;
    if (this.props.divider && this.props.divider === 'top') {
      divider = <div className="dropdown-divider"></div>;
    }

    return (
      <div className={type}>
        {divider}
        <a
          href={url}
          target={target}
          data-remote={data && data.remote}
          data-method={data && data.method}
          data-confirm={data && data.confirm}
          onMouseDownCapture={this.handleMouseDown}
          data-turbolinks={data && data.turbolinks}
          data-sort-value={data && data['sort-value']}
          data-filter-value={data && data['filter-value']}
          data-display-setting={data && data['display-setting']}
          className={className}
        >
          {image(this.props)}
          <span className={(this.props.image || fa) ? 'icon-left' : ''}>
            {title}
          </span>
        </a>
      </div>
    );
  }
}

LinkItem.propTypes = propTypes;

export default LinkItem;
