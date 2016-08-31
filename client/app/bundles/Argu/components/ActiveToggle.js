/* global Bugsnag, fetch */
import React, { Component, PropTypes } from 'react';
import { safeCredentials } from '../lib/helpers';

const propTypes = {
  initialState: PropTypes.bool,
  label: PropTypes.oneOfType([
    PropTypes.bool,
    PropTypes.string,
  ]),
  tagName: PropTypes.string,
  url: PropTypes.string,
};

const defaultProps = {
  tagName: 'div',
};

class ActiveToggle extends Component {
  constructor(props) {
    super(props);
    this.state = {
      toggleState: this.props.initialState,
      loading: false,
      tagName: this.props.tagName,
    };
  }

  handleClick() {
    const newState = this.state.toggleState;
    this.setState({ loading: true });

    fetch(decodeURI(this.props.url).replace(/{{value}}/, newState.toString()), safeCredentials({
      method: this.props[`${newState}_props`].method || 'PATCH',
    })).then(response => {
      if (response.status === 201 || response.status === 304) {
        this.setState({ toggleState: true });
      } else if (response.status === 204) {
        this.setState({ toggleState: false });
      } else {
        Bugsnag.notify('ActiveToggle:33');
      }
      this.setState({ loading: false });
    });
  }

  render() {
    const currentProps = this.props[`${this.state.toggleState}_props`];
    let label;
    if (this.props.label !== false) {
      label = <span className="icon-left">{currentProps.label}</span>;
    }

    return (
      <this.state.tagName
        onClick={this.handleClick}
        className={this.state.loading ? 'is-loading' : ''}
      >
        <span className={`fa fa-${currentProps.icon}`}></span>
        {label}
      </this.state.tagName>
    );
  }
}

ActiveToggle.propTypes = propTypes;
ActiveToggle.defaultProps = defaultProps;

export default ActiveToggle;
