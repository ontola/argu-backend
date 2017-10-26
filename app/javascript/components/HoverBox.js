import React, { Component, PropTypes } from 'react';

const propTypes = {
  /** Always visible. Functions as a trigger that responds to hover or focus. */
  children: PropTypes.node.isRequired,
  /** Only show when hovering over the trigger / children */
  hiddenChildren: PropTypes.node.isRequired,
};

const defaultProps = {
  children: '',
};

/**
 * Mouse-first component designed to add some extra info where requested. Since it uses 'hover'
 * state, make sure to add functionality for touch users.
 * @returns {component} Component
 */
export class HoverBox extends Component {
  constructor(props) {
    super(props);
    this.state = {
      isVisible: false,
    };

    this.showContent = this.showContent.bind(this);
    this.hideContent = this.hideContent.bind(this);
  }

  showContent() {
    this.setState({
      isVisible: true,
    });
  }

  hideContent() {
    this.setState({
      isVisible: false,
    });
  }

  // The trigger is always visisble and contains the children.
  // When the user hovers over them, the hiddenChildren appear.
  trigger(children) {
    return (
      <span
        onMouseEnter={this.showContent}
        onMouseLeave={this.hideContent}
        onFocus={this.showContent}
        onBlur={this.hideContent}
        tabIndex="0"
      >
        {children}
      </span>
    );
  }

  className() {
    return this.state.isVisible
      ? 'HoverBox__hidden-part--visible'
      : 'HoverBox__hidden-part--hidden';
  }

  render() {
    return (
      <div className="HoverBox">
        {this.trigger(this.props.children)}
        <div className={`HoverBox__hidden-part ${this.className()}`}>
          {this.props.children}
          {this.state.isVisible && this.props.hiddenChildren}
        </div>
      </div>
    );
  }

}

HoverBox.propTypes = propTypes;
HoverBox.defaultProps = defaultProps;

export default HoverBox;
