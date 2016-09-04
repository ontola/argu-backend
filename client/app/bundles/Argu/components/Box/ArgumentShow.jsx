import React from 'react';
import { Box } from 'components';

const argumentButtons = [{
  icon: 'comment',
  label: 'Reageer',
}, {
  icon: 'arrow-up',
  label: 'Upvote',
}];

const ArgumentShow = (props) => (
  <Box
    {...props}
    boxActions={argumentButtons}
    showMeta
    headingSize="3"
  />
);

export default ArgumentShow;
