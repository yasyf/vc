const merge = require('webpack-merge')
const sharedConfig = require('./shared.js')
const { settings, output } = require('./configuration.js')

module.exports = merge(sharedConfig, {
  devtool: 'cheap-eval-source-map',

  stats: {
    errorDetails: true
  },

  output: {
    pathinfo: true
  },
})
