import moment from 'moment';

const dateDisplayFormat = 'DD-MM-YYYY';

/**
 * @param {number} timestamp A unix timestamp
 * @return {string} A formatted date string
 */
const formatDate = (timestamp) => {
  if (!timestamp) {
    return undefined;
  }

  const dateMilliSeconds = new Date(timestamp);
  const formattedDate = moment(dateMilliSeconds).format(dateDisplayFormat);
  return formattedDate;
};

export {
  formatDate,
};
