import React from 'react';
import ReactOnRails from 'react-on-rails';

const Expander = React.createClass({
  propTypes: {
    className: React.PropTypes.string,
    expanderTarget: React.PropTypes.string,
    label: React.PropTypes.oneOfType([
      React.PropTypes.object,
      React.PropTypes.string,
    ]),
    showCaret: React.PropTypes.bool,
    url: React.PropTypes.string,
  },

  getInitialState() {
    return {
      openState: false,
    };
  },

  toggleOpenState() {
    document.getElementById(this.props.expanderTarget).setAttribute('opened', !this.state.openState ? 'opened' : 'closed');
    document.getElementById(this.props.expanderTarget).style.display = !this.state.openState ? 'block' : 'none';
    this.setState({ openState: !this.state.openState });
  },

  handleClick(e) {
    e.preventDefault();
    this.toggleOpenState();
  },

  url() {
    if (this.props.url) {
      return `#${this.props.url}`;
    } else {
      return '';
    }
  },

  render() {
    let label, showCaret;
    if (typeof this.props.label === 'object') {
      label = this.state.openState ? this.props.label.opened : this.props.label.closed;
    } else {
      label = this.props.label;
    }
    if (this.props.showCaret) {
      showCaret = (<span className={`fa fa-angle-${this.state.openState ? 'up' : 'down'}`}></span>);
    }

    return (
      <a
        href={this.url()} className={`expander ${this.props.className}`}
        onClickCapture={this.handleClick}
        data-skip-pjax
      >
        {label}
        {showCaret}
      </a>
    );
  },
});

ReactOnRails.register({ Expander });
