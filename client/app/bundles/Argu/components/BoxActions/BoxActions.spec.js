import React from 'react';
import { mount } from 'enzyme';
import { assert } from 'chai';

import BoxActions from './';

const buttons = [{
  label: 'Button 1',
  action: () => {},
}, {
  label: 'Button 1',
  action: () => {},
}];

const wrapper = mount(<BoxActions buttons={buttons} />);


describe('Box actions', () => {
  it('should render', () => {
    assert.equal(
      wrapper.find('.Button').length,
      buttons.length,
      'Not the right amount of buttons found'
    );

    // wrapper.find('button').first().simulate('click');
  });
});
