assign = require 'object-assign'
webpack = require 'webpack'
WebpackDevServer = require 'webpack-dev-server'
webpackDevConfig = require './configs/webpack.config'
browserSync = require 'browser-sync'
proxyMiddleware = require 'http-proxy-middleware'
gutil = require 'gulp-util'
express = require "webpack-dev-server/node_modules/express"
path = require 'path'
cwd = process.cwd()
_ = require 'lodash'

module.exports = (opts,mode)->
    opts = _.cloneDeep opts

    logData = (data)->
        gutil.log gutil.colors.bold gutil.colors.blue(data)

    logData('Name : '+opts.name );
    logData('PORT : '+ opts.server.webPort );
    logData('Environment : '+ opts.env );

    # 获得代理域名
    middlewareProxy = []

    if opts.server.isProxy
        opts.server.proxyUrl.map (url)->
            middlewareProxy.push proxyMiddleware url, {
                target: opts.server.proxyHost
                changeOrigin: true
            }

    options =
        ui: false
        server: path.join cwd, opts.webpack.base.output
        port: opts.server.webPort
        logFileChanges: false
        middleware: middlewareProxy
        ghostMode: false #Clicks, Scrolls & Form inputs on any device will be mirrored to all others.
        notify: false #The small pop-over notifications in the browser are not always needed/wanted.
        open: "external"

    if opts.server.liveload
        options.files = [ path.join(cwd,opts.webpack.output) + '/**/*']

    browserSync.init(options)
