module.exports = {
  test: /\.js(\.erb)?$/,
  exclude: /node_modules\/(?!parse-domain)/,
  loader: 'babel-loader',
};
