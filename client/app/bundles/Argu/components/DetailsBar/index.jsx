import './DetailsBar.scss';
import React, { PropTypes } from 'react';

const DetailsBar = ({ children }) => (
  <div className="DetailsBar">
    {children}
  </div>
);

DetailsBar.propTypes = {
  children: PropTypes.node.isRequired,
};

export default DetailsBar;
