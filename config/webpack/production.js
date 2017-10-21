// Note: You must restart bin/webpack-dev-server for changes to take effect

/* eslint global-require: 0 */

const webpack = require('webpack');
const merge = require('webpack-merge');
const CompressionPlugin = require('compression-webpack-plugin');
const SWPrecacheWebpackPlugin = require('sw-precache-webpack-plugin');
const ClosureCompilerPlugin = require('webpack-closure-compiler');
const sharedConfig = require('./shared.js');

module.exports = merge(sharedConfig, {
  output: { filename: '[name]-[chunkhash].js' },
  devtool: 'source-map',
  stats: 'normal',
  plugins: [
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.AggressiveMergingPlugin(),
    new webpack.optimize.OccurrenceOrderPlugin(),
    new ClosureCompilerPlugin({
      compiler: {
        compilation_level: 'ADVANCED',
      },
      concurrency: 3,
      exclude: [/\.min\.js$/gi],
    }),
    new CompressionPlugin({
      asset: '[path].gz[query]',
      algorithm: 'gzip',
      test: /\.(js|css|html|json|ico|svg|eot|otf|ttf)$/
    }),
    new SWPrecacheWebpackPlugin({
      minify: true,
      staticFileGlobsIgnorePatterns: [/\.map$/, /manifest\.json$/],
      mergeStaticsConfig: true,
    }),
  ]
})
