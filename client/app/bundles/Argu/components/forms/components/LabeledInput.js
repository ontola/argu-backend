import React, { PropTypes } from 'react';

const propTypes = {
  children: PropTypes.node,
  input: PropTypes.node,
  label: PropTypes.string,
};

const LabeledInput = ({ children: child, label }) => (
  <li className="input">
    <label htmlFor={child.id}>{label}</label>
    {child}
  </li>
);

LabeledInput.propTypes = propTypes;

export default LabeledInput;
