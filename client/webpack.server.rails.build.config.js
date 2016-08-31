// Webpack configuration for server bundle
const webpack = require('webpack');
const path = require('path');
const devBuild = process.env.NODE_ENV !== 'production';
const nodeEnv = devBuild ? 'development' : 'production';

module.exports = {
  // the project dir
  context: __dirname,
  entry: [
    'babel-polyfill',
    './vendor/i18n/i18n',
    './vendor/i18n/translations',
    './app/bundles/Argu/startup/serverRegistration',
  ],
  output: {
    filename: 'server-bundle.js',
    path: '../app/assets/webpack',
  },

  resolve: {
    extensions: ['', '.js', '.jsx'],
    alias: {
      lib: path.join(process.cwd(), 'app', 'lib'),
      eventEmitter$: 'wolfy87-eventemitter',
      'isomorphic-fetch': 'whatwg-fetch',
    },
  },
  plugins: [
    new webpack.DefinePlugin({
      'process.env': {
        NODE_ENV: JSON.stringify(nodeEnv),
      },
    }),
  ],
  module: {
    loaders: [
        { test: /(\.jsx|\.js)?$/, loader: 'babel-loader', exclude: /node_modules/ },
        { test: /\.json$/, loader: 'json-loader' },
        { test: require.resolve('./vendor/i18n/i18n'), loader: 'expose?I18n' },
    ],
  },
};
