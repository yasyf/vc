// Note: You must restart bin/webpack-dev-server for changes to take effect

/* eslint global-require: 0 */

const webpack = require('webpack')
const merge = require('webpack-merge')
const CompressionPlugin = require('compression-webpack-plugin')
const sharedConfig = require('./shared.js')

module.exports = merge(sharedConfig, {
  output: { filename: '[name]-[chunkhash].js' },
  devtool: 'source-map',
  stats: 'normal',

  plugins: [
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.AggressiveMergingPlugin(),
    new webpack.optimize.OccurrenceOrderPlugin(),
    new webpack.optimize.UglifyJsPlugin({
      minimize: true,
      sourceMap: false,
      compress: {
        warnings: false,
        unused: true,
        dead_code: true,
        drop_debugger: true,
        drop_console: true,
        conditionals: true,
        comparisons: true,
        sequences: true,
        booleans: true
      },
      output: {
        comments: false
      },
      exclude: [/\.min\.js$/gi]
    }),
    new webpack.IgnorePlugin(/^\.\/locale$/, [/moment$/]),
    new CompressionPlugin({
      asset: '[path].gz[query]',
      algorithm: 'gzip',
      test: /\.(js|css|html|json|ico|svg|eot|otf|ttf)$/
    })
  ]
})
