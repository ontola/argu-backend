import './Detail.scss';
import React, { PropTypes } from 'react';
import { browserHistory } from 'react-router';

const propTypes = {
  className: PropTypes.string,
  text: PropTypes.string,
  url: PropTypes.string,
  icon: PropTypes.string,
  imageUrl: PropTypes.string,
  title: PropTypes.string,
};

const Detail = ({
  text,
  icon,
  url,
  imageUrl,
  className,
  title,
}) => {
  const Element = url ? 'a' : 'div';
  const classNames = ['Detail', className].join(' ');
  const pictogram = imageUrl
    ? <img src={imageUrl} className="Detail__icon" role="presentation" />
    : <span className={`Detail__icon fa fa-${icon}`} />;

  return (
    <Element
      onClick={(e) => {
        e.preventDefault();
        if (url) browserHistory.push(url);
      }}
      href={url}
      className={classNames}
      title={title}
    >
      {(icon || imageUrl) && pictogram}
      <span className="Detail__text">{text}</span>
    </Element>
  );
};

Detail.propTypes = propTypes;

export default Detail;
