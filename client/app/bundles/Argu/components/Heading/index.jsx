import './Heading.scss';
import React, { PropTypes } from 'react';
import classNames from 'classnames';
import { headingSizes, headingVariants } from 'components/shared/config';

const propTypes = {
  children: PropTypes.node.isRequired,
  size: PropTypes.oneOf(headingSizes),
  variant: PropTypes.oneOf(headingVariants),
};

const defaultProps = {
  children: '',
  size: '2',
};

const Heading = ({
  children,
  size,
  variant,
}) => {
  const Element = `h${size}`;
  const headingClass = classNames({
    Heading: true,
    [`Heading--${variant}`]: variant,
  });

  return (
    <Element
      children={children}
      className={headingClass}
      role="heading"
    />
  );
};

Heading.propTypes = propTypes;
Heading.defaultProps = defaultProps;

export default Heading;
