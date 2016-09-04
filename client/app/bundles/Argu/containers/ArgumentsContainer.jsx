
import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
// import { getArgs } from 'state/argumentations/selectors';
import {
  ArgumentListItem,
  Columns,
  List,
} from 'components';

const propTypes = {
  motionId: PropTypes.string.isRequired,
  argumentations: PropTypes.array.isRequired,
};

const defaultProps = {
  argumentations: [],
};

const renderItem = (arg) => (
  <ArgumentListItem
    key={arg.id}
    title={arg.title}
    content={arg.content}
    side={arg.side}
  />
);

const ArgumentsContainer = ({ argumentations }) => {
  const argumentsPro = argumentations.filter(arg => arg.side === 'pro');
  const argumentsCon = argumentations.filter(arg => arg.side === 'con');

  if (argumentations.length > 0) {
    return (
      <Columns>
        <List items={argumentsPro} renderItem={renderItem} />
        <List items={argumentsCon} renderItem={renderItem} />
      </Columns>
    );
  }
  return false;
};

ArgumentsContainer.propTypes = propTypes;
ArgumentsContainer.defaultProps = defaultProps;

export default connect(
  (state, ownProps) => ({
    argumentations: getArgs(state, ownProps),
  })
)(ArgumentsContainer);
