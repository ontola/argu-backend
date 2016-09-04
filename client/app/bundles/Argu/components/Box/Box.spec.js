import React from 'react';
import { mount } from 'enzyme';
import { assert } from 'chai';

import Box from './';

const wrapper = mount(
  <Box
    children="Test content"
    date={1471869335}
    link="/test"
    showMeta
    showLink
    title="Test title"
    type="Test"
  />
);

describe('Box component', () => {
  it('should render', () => {
    assert.isDefined(wrapper.props().children, 'Children have not been born yet...');
    assert.equal(wrapper.find('.Heading').length, 1, 'There is no heading');
    assert.equal(wrapper.find('.Box__content').length, 1, 'There is no content');
    assert.equal(wrapper.find('.Heading a').length, 1, 'No link has been found');
    assert.equal(wrapper.find('.DetailsBar').length, 1, 'No meta info found');
    assert.isAbove(wrapper.find('.Detail').length, 1, 'Not enough meta info found');
  });
});
