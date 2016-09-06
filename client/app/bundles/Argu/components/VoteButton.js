/* globals I18n */
import React, { Component, PropTypes } from 'react';

const propTypes = {
  actor: PropTypes.object,
  clickHandler: PropTypes.func,
  count: PropTypes.number,
  current: PropTypes.bool,
  side: PropTypes.oneOf([
    'con',
    'neutral',
    'pro',
  ]),
  turbolinks: PropTypes.bool,
  voteableId: PropTypes.string,
  voteableType: PropTypes.string,
};

/**
 * Component for the POST-ing of a vote.
 * This component is not pure.
 * @class VoteButtons
 * @export VoteButtons
 * @memberof Vote
 */
class VoteButton extends Component {
  iconForSide() {
    switch (this.props.side) {
      case 'con':
        return 'thumbs-down';
      case 'pro':
        return 'thumbs-up';
      case 'neutral':
      default:
        return 'pause';
    }
  }

  render() {
    const {
      clickHandler,
      count,
      current,
      side,
      turbolinks,
      voteableId,
    } = this.props;

    let voteCountElem;
    if (count !== 0) {
      voteCountElem = <span className="vote-count">{count}</span>;
    }

    return (
      <li>
        <a
          className={`btn-${side}`}
          data-turbolinks={turbolinks ? undefined : 'false'}
          data-voted-on={current}
          href={`/m/${voteableId}/v/${side}`}
          onClickCapture={clickHandler}
          rel="nofollow"
        >
          <span className={`fa fa-${this.iconForSide()}`} />
          <span className="vote-text">
            {I18n.t(`votes.type.${side}`)}
          </span>
          {voteCountElem}
        </a>
      </li>
    );
  }
}

VoteButton.propTypes = propTypes;

export default VoteButton;
