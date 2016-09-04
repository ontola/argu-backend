import './Box.scss';
import React, { PropTypes } from 'react';
import { Link } from 'react-router';

import { BoxActions, Detail, DetailsBar, Heading } from 'components';
import PersonContainer from 'containers/PersonContainer';
// import ArgumentsContainer from 'containers/ArgumentsContainer';
import { formatDate } from 'helpers/date';
import { headingSizes, headingVariants } from 'components/shared/config';

const propTypes = {
  author: PropTypes.string,
  boxActions: PropTypes.array,
  children: PropTypes.node,
  date: PropTypes.number,
  id: PropTypes.string,
  headingSize: PropTypes.oneOf(headingSizes),
  headingVariant: PropTypes.oneOf(headingVariants),
  link: PropTypes.string,
  showArguments: PropTypes.bool,
  showLink: PropTypes.bool,
  showButtons: PropTypes.bool,
  showMeta: PropTypes.bool,
  title: PropTypes.string,
  type: PropTypes.string,
  voteData: PropTypes.string,
};

const defaultProps = {
  boxActions: [],
  headingSize: '2',
  headingVariant: 'default',
  type: undefined,
  voteData: undefined,
};

const THOUSAND = 1000;

const Box = ({
  author,
  boxActions,
  children,
  date,
  headingSize,
  headingVariant,
  id,
  link,
  showArguments,
  showLink,
  showMeta,
  title,
  type,
  voteData,
}) => (
  <div className="Box">
    <div className="Box__content">
      {title &&
        <Heading size={headingSize} variant={headingVariant}>
          {showLink && link
            ? <Link to={link} dangerouslySetInnerHTML={{ __html: title }} />
            : <div dangerouslySetInnerHTML={{ __html: title }} />}
        </Heading>
      }

      {showMeta &&
        <DetailsBar>
          {type && <Detail text={type} icon="file-o" />}
          {author && <PersonContainer user={author} />}
          {date && <Detail text={formatDate(date * THOUSAND)} icon="clock-o" />}
        </DetailsBar>
      }

      <div className="Box__content-main">{children}</div>

    </div>
  </div>
);


      // {showArguments &&
      //   <ArgumentsContainer motionId={id} />
      // }
Box.propTypes = propTypes;
Box.defaultProps = defaultProps;

export default Box;
