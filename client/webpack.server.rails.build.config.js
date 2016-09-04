// Webpack configuration for server bundle
const webpack = require('webpack');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
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

      actions: path.resolve('app/bundles/Argu/actions'),
      components: path.resolve('app/bundles/Argu/components'),
      containers: path.resolve('app/bundles/Argu/containers'),
      helpers: path.resolve('app/bundles/Argu/helpers'),
      models: path.resolve('app/bundles/Argu/records'),
      react: path.resolve('./node_modules/react'),
      state: path.resolve('app/bundles/Argu/state'),
    },
  },
  plugins: [
    new webpack.DefinePlugin({
      'process.env': {
        NODE_ENV: JSON.stringify(nodeEnv),
      },
      'process.env.ELASTICSEARCH_URL': JSON.stringify(process.env.ELASTICSEARCH_URL),
      __DEVELOPMENT__: process.env.NODE_ENV === 'development',
      __PRODUCTION__: process.env.NODE_ENV === 'production',
    }),
    new ExtractTextPlugin('bundle.css'),
  ],
  module: {
    loaders: [
        { test: /(\.jsx|\.js)?$/, loader: 'babel-loader', exclude: /node_modules/ },
        { test: /\.scss$/, loader: ExtractTextPlugin.extract('style-loader', 'css-loader!postcss-loader!sass-loader') },
        { test: /\.json$/, loader: 'json-loader' },
        { test: require.resolve('./vendor/i18n/i18n'), loader: 'expose?I18n' },
    ],
  },
};
