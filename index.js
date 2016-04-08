module.exports = {
  server: require('./lib/server'),
  BsServer: require('./lib/bs-server'),
  compiler: require('./lib/compiler'),
  karma: require('./lib/karma'),
  util: {
    assign: require('object-assign')
  }
};
