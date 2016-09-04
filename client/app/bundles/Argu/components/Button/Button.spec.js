import React from 'react';
import { mount } from 'enzyme';
import { assert } from 'chai';

import Button from './';

describe('Button component', () => {
  const buttonReqProps = mount(<Button children="Button label" />);
  const buttonAllProps = mount(
    <Button
      children="joe"
      icon="lightbulb-o"
      small
      theme="subtle"
      variant="pro"
    />
  );

  describe('with only the required props', () => {
    it('should have a label', () => {
      assert.isAbove(buttonReqProps.props().children.length, 0, 'Button has no label');
    });

    it('should not have an icon', () => {
      assert.equal(buttonReqProps.find('.fa').length, 0, 'Icon has been found');
    });
  });

  describe('with all props', () => {
    it('should have a label', () => {
      assert.isAbove(buttonAllProps.props().children.length, 0, 'Button has no label');
    });

    it('should have an icon', () => {
      assert.equal(buttonAllProps.find('.fa').length, 1, 'No icon has been found');
    });

    it('should be small', () => {
      assert.equal(buttonAllProps.find('.Button--small').length, 1, 'Button is not small');
    });

    it('should have the \'subtle\' theme', () => {
      assert.equal(
        buttonAllProps.find('.Button--subtle').length,
        1,
        'Button does not have the correct theme'
      );
    });

    it('should be the \'pro\' variant', () => {
      assert.equal(
        buttonAllProps.find('.Button--variant-pro').length,
        1,
        'Button is not the correct variant'
      );
    });
  });
});
