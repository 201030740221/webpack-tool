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
    serverConfig = {
        contentBase: opts.server.entry
        publicPath: opts.server.publicPath
        hot: opts.webpack.base.hot || false
        stats:
            colors: true,
            progress: true
        watchOptions:
            aggregateTimeout: 100
        noInfo: true
    }

    serverPort = opts.server.devPort || 3210


    logData = (data)->
        gutil.log gutil.colors.bold gutil.colors.blue(data)

    logData('Name : '+opts.name );
    logData('PORT : '+ opts.server.webPort );
    logData('WEBPACK DEV SERVER PORT : '+ serverPort);
    logData('WEBPACK DEV SERVER HOST : '+ "localhost");
    logData('Environment : '+ opts.env );

    #Start a webpack-dev-server
    webpackDevCompiler = webpack(webpackDevConfig(opts || {}, mode))

    bundleStart = null
    webpackDevCompiler.plugin 'compile', ->
        gutil.log('编译中...');
        bundleStart = Date.now()

    webpackDevCompiler.plugin 'done', ->
        gutil.log('编译耗时 ' + (Date.now() - bundleStart) + 'ms!')

    devServer = new WebpackDevServer webpackDevCompiler, serverConfig

    devServer.app.use express.static path.join cwd, '/dist/'+opts.version

    devServer.listen serverPort, "0.0.0.0", (err)->
        throw err if err
        gutil.log('正准备编译项目，请耐心等待...');

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
            proxy: "localhost:" + serverPort
            port: opts.server.webPort
            logFileChanges: false
            middleware: middlewareProxy
            ghostMode: false #Clicks, Scrolls & Form inputs on any device will be mirrored to all others.
            notify: false #The small pop-over notifications in the browser are not always needed/wanted.
            open: "external"

        if opts.server.liveload
            options.files = [ opts.server.entry + '/**']

        browserSync(options)

        if opts.callback
            opts.callback()
