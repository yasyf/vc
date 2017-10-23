const webpack = require('webpack');
const { environment } = require('@rails/webpacker');

// Don't use commons chunk for server_side_render chunk
const entries = environment.toWebpackConfig().entry;
const commonsChunkEligible = Object.keys(entries).filter(name => name !== 'server_side_render');

environment.plugins.set('CommonsChunkVendor', new webpack.optimize.CommonsChunkPlugin({
  name: 'vendor',
  minChunks: (module, count) => {
    // this assumes your vendor imports exist in the node_modules directory
    return module.context && module.context.indexOf('node_modules') !== -1;
  },
  chunks: commonsChunkEligible
}));

environment.plugins.set('CommonsChunkManifest', new webpack.optimize.CommonsChunkPlugin({
  name: 'manifest',
  minChunks: Infinity
}));

module.exports = environment;