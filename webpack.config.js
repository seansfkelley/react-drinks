const webpack = require('webpack');
const WebpackNotifierPlugin = require('webpack-notifier');

// const VENDOR_LIBS = Object.keys(require('./package.json').dependencies);

module.exports = {
  entry: {
    app: './frontend/endpoints/app/app-init.cjsx',
    recipe: './frontend/endpoints/recipe/recipe-init.cjsx'
  },
  output: {
    path: '.dist/',
    publicPath: '/',
    filename: '[name].js'
  },
  module: {
    loaders: [
      { test: /\.cjsx$/, loader: 'coffee!cjsx' },
      { test: /\.coffee$/, loader: 'coffee' },
      { test: /node_modules.*\.js$/, loader: 'source-map-loader' },
      { test: /\.css$/, loader: 'style!css' },
      { test: /\.styl/, loader: 'style!css?sourceMap!stylus' }
    ]
  },
  resolve: {
    extensions: ['', '.coffee', '.cjsx', '.js']
  },
  devtool: 'source-map',
  plugins: [
    new WebpackNotifierPlugin({
      title: 'react-drinks'
    })
  ]
};
