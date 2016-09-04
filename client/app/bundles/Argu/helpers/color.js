/**
 * @param {string} str A rgb color string
 * @return {bool} True if string is rgb
 */
const isRGB = str => /^rgb\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3})\)$/.test(str);

/**
 * @param {string} rgb A rgb color string
 * @return {array} An Array of the rgb values
 */
const rgbToArray = rgb => rgb.replace(/[^\d,]/g, '').split(',');

/**
 * For more info on this see check these links:
 * http://www.w3.org/TR/2008/REC-WCAG20-20081211/#relativeluminancedef
 * https://en.wikipedia.org/wiki/Rec._709#Luma_coefficients
 * @param {string} rgb A rgb color string
 * @return {string} luminance index number of rgb string
 */
const getLuminance = rgb => {
  const LIMIT = 255;
  const DECIMALS = 2;
  const aR = 0.299;
  const aG = 0.587;
  const aB = 0.117;
  const coefficients = [aR, aG, aB];
  let rgbArray;

  if (!Array.isArray(rgb)) {
    rgbArray = rgbToArray(rgb);
  } else {
    rgbArray = rgb;
  }

  const all = coefficients.map((a, i) => rgbArray[i] / LIMIT * a);
  return all.reduce((prev, curr) => prev + curr).toFixed(DECIMALS);
};


/**
 * @constant
 * @type {number}
 */
const defaultLuminanceTreshold = 0.5;


/**
 * @param {string} rgb A rgb color string
 * @param {number} threshold A decimal number
 * @return {bool} True if luminance is below threshold
 */
const checkLuminance = (
  rgb,
  threshold = defaultLuminanceTreshold
) => getLuminance(rgb) < threshold;


export {
  isRGB,
  checkLuminance,
  rgbToArray,
  getLuminance,
};
