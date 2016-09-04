/* eslint no-magic-numbers: 0 */
import { assert } from 'chai';
import {
  checkLuminance,
  getLuminance,
  isRGB,
  rgbToArray,
} from './color';

const rgbInput = 'rgb(230, 48, 205)';
const rgbArray = ['230', '48', '205'];
const threshold = 0.5;
const expectedLuminationValue = 0.47;

describe('RGB Color value', () => {
  it('should transform rgb value to array', () => {
    const test = rgbToArray(rgbInput);
    assert.deepEqual(test, rgbArray, 'Could not convert string to array properly');
  });

  it('should have the correct luminance value', () => {
    assert.equal(
      getLuminance(rgbInput),
      expectedLuminationValue,
      'Value not correct according to weighted W3C method'
    );

    assert.equal(
      getLuminance(rgbArray),
      expectedLuminationValue,
      'Value not correct according to weighted W3C method'
    );
  });

  it('should check whether string is a rgb color code', () => {
    assert.isTrue(isRGB(rgbInput), 'String is not a rgb color');
  });

  it('should return the correct boolean when checked with threshold value', () => {
    assert.equal(checkLuminance(rgbInput, threshold), true, 'Boolean value incorrect');
  });
});
