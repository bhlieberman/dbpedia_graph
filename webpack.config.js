const path = require('path')

module.exports = {
  devServer: {
    static: {
      directory: path.join(__dirname, 'assets'),
    },
    port: 9000,
    hot: false,
    liveReload: true,
  },
  output: {
    path: __dirname,
    filename: 'assets/bundle.js'
  }
}