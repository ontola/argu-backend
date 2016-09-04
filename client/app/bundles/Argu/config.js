/* eslint no-magic-numbers: 0 */
const PORT_DEVELOPMENT = process.env.PORT_DEVELOPMENT || 3001;
const PORT_PRODUCTION = process.env.PORT_PRODUCTION || 8080;
const PORT = process.env.PORT || (__DEVELOPMENT__ ? PORT_DEVELOPMENT : PORT_PRODUCTION);

// Used internally in the router as a reverse proxy
const ARGU_API_URL = process.env.ARGU_API_URL || 'http://localhost:1337/aod-search.argu.co/';

// Used externally as the endpoint for API calls by the browser app
const ARGU_API_URL_EXT = process.env.ARGU_API_EXT_BASE || 'http://localhost:1337/aod-search.argu.co/api/';

const ELASTICSEARCH_URL = process.env.ELASTICSEARCH_URL || 'https://aod-search.argu.co/aod_search/';
const ELASTICSEARCH_INDEX = process.env.ELASTICSEARCH_INDEX || 'aod';

export {
  PORT,
  ARGU_API_URL,
  ARGU_API_URL_EXT,
  ELASTICSEARCH_URL,
  ELASTICSEARCH_INDEX,
};
