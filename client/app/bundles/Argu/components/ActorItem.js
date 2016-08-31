import React, { Component, PropTypes } from 'react';
import { image } from '../lib/helpers';

const propTypes = {
  actorUpdate: PropTypes.func,
  data: PropTypes.shape({
    turbolinks: PropTypes.string,
  }),
  divider: PropTypes.string,
  done: PropTypes.func,
  fa: PropTypes.string,
  id: PropTypes.number,
  image: PropTypes.object,
  title: PropTypes.string,
  type: PropTypes.string,
  update_url: PropTypes.string,
};

class ActorItem extends Component {
  constructor() {
    super();
    this.state = {};
  }

  handleClick(e) {
    e.preventDefault();
  }

  handleTap() {
    this.props.actorUpdate(this.props.id);
  }

  handleMouseDown(e) {
    e.preventDefault();
    this.props.actorUpdate(this.props.id);
  }

  render() {
    let divider;
    let turbolinks;
    if (this.props.divider && this.props.divider === 'top') {
      divider = <div className="dropdown-divider"></div>;
    }
    if (this.props.data) {
      turbolinks = this.props.data.turbolinks;
    }

    return (
      <div className={`link ${this.props.type}`}>
        {divider}
        <a
          href="#"
          onMouseDownCapture={this.handleMouseDown}
          rel="nofollow"
          onTouchEnd={this.handleTap}
          onClickCapture={this.handleClick}
          data-turbolinks={turbolinks}
        >
          {image(this.props)}
          <span className={(this.props.image || this.props.fa) ? 'icon-left' : ''}>
            {this.props.title}
          </span>
        </a>
      </div>
    );
  }
}

ActorItem.propTypes = propTypes;

export default ActorItem;
