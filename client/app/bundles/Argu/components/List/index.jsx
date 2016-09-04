import './List.scss';
import React, { PropTypes } from 'react';

const propTypes = {
  items: PropTypes.oneOfType([
    PropTypes.array,
    PropTypes.object,
  ]).isRequired,
  renderItem: PropTypes.func.isRequired,
  align: PropTypes.oneOf([
    'horizontal',
    'vertical',
  ]),
};

const defaultProps = {
  items: {},
  align: 'vertical',
};

const List = ({ items, renderItem, align }) => (
  <div className={(align === 'horizontal') ? 'List List--horizontal' : 'List'}>
    {items.constructor === Array ? items.map(renderItem) : items.valueSeq().map(renderItem)}
  </div>
);

List.propTypes = propTypes;
List.defaultProps = defaultProps;

export default List;
