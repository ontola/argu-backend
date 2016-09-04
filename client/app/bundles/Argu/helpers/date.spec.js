import { assert } from 'chai';
import { formatDate } from './date';

const TIMESTAMP = 1457172000000;
const expectedOutput = '05-03-2016';

describe('Date', () => {
  it('format correctly', () => {
    assert.equal(formatDate(TIMESTAMP), expectedOutput, 'Date is not formatted correctly');
  });
});
