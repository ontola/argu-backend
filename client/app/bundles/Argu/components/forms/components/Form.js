import React, { PropTypes } from 'react';
import { getAuthenticityToken } from '../../../lib/helpers';

const propTypes = {
  action: PropTypes.string,
  authenticityToken: PropTypes.string,
  children: PropTypes.oneOfType([
    PropTypes.arrayOf(PropTypes.node),
    PropTypes.node,
  ]),
  method: PropTypes.string,
};

const Form = props => {
  const { authenticityToken, children, method } = props;

  return (
    <form {...props} method="post">
      <ol>
          {children}
      </ol>
      <input type="hidden" name="_method" value={method || 'post'} />
      <input
        type="hidden"
        name="authenticity_token"
        value={authenticityToken || getAuthenticityToken()}
      />
    </form>
  );
};

Form.propTypes = propTypes;

export default Form;
