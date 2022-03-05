/* eslint-disable global-require */

const { environment } = require('@rails/webpacker');
const merge = require('webpack-merge');
const erb = require('./loaders/erb');

const sassLoaderOptions = {
  includePaths: environment.toWebpackConfig().resolveLoader.modules,
  implementation: require('sass'),
};

const CSSLoader = environment.loaders.get('sass').use.find((el) => el.loader === 'sass-loader');

CSSLoader.options = merge(CSSLoader.options, sassLoaderOptions);

environment.splitChunks();

environment.loaders.prepend('erb', erb);
module.exports = environment;
