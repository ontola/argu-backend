import React from 'react';
import { shallow } from 'enzyme';
import { assert } from 'chai';

import List from './';

const items = ['1', '2', '3'];
const renderItem = (id) => <div key={id}>{id}</div>;
const wrapper = shallow(<List items={items} renderItem={renderItem} />);

describe('List component', () => {
  it('should render all items in array/object', () => {
    assert.equal(
      items.length,
      wrapper.find('.List > div').length,
      'Items length does not equal to rendered list'
    );
  });
});
