webpack = require('webpack')
webpackDevConfig = require('./configs/webpack.config')
_ = require 'lodash'

module.exports = (opts, mode)->
    opts = _.cloneDeep opts
    webpackDevCompiler = webpack(webpackDevConfig(opts, mode))
