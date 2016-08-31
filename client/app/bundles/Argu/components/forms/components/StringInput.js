import React, { PropTypes } from 'react';
import LabeledInput from './LabeledInput';

const propTypes = {
  label: PropTypes.string,
  name: PropTypes.string,
  value: PropTypes.string,
};

const StringInput = props => {
  const { label, name, value } = props;
  return (
    <LabeledInput label={label}>
      <input
        type="string"
        value={value}
        name={name}
        {...props}
      />
    </LabeledInput>
  );
};

StringInput.propTypes = propTypes;

export default StringInput;
