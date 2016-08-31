
/**
 * Replace an item in the array arr with newElem without modifying the original.
 * The order of the array isn't kept.
 * @param {Array} arr The old array
 * @param {number} index Index of the element in arr
 * @param {Object} newElem The object to insert into the array
 * @return {Array} Array with the item replaced.
 **/
export function replaceIndexedItem(arr, index, newElem) {
  let newArr = [newElem];
  if (arr.length > 1) {
    if (index !== 0) {
      newArr = newArr.concat(arr.slice(0, index));
      newArr = newArr.concat(arr.slice(index - arr.length + 1));
    } else {
      newArr = newArr.concat(arr.slice(1));
    }
  }
  return newArr;
}
