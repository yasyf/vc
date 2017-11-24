module.exports = {
  test: /\.(js|jsx)?(\.erb)?$/,
  exclude: /node_modules\/(?!react-dimensions)/,
  loader: 'babel-loader',
}
