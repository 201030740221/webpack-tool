assign = require 'object-assign'
webpackDevConfig = require './webpack.config'
opts = require './dev.config'
webpackTool = require '../../index'
getLoaders = require '../configs/getloaders'
gutil = require('gulp-util')
defaultConfig = require './default.config.js'
path = require 'path'
cwd = process.cwd()

# 处理 loader
loaders = getLoaders(opts);

env = gutil.env.env || opts.env

# 获取对应环境的设置
webpackConfig = assign defaultConfig.webpack.base, opts.webpack.base, if opts.webpack[env] then opts.webpack[env] else defaultConfig.webpack[env];

module.exports = (config)->

    preprocessors = {}
    preprocessors[cwd + '/_test/*']=['webpack', 'sourcemap']

    settings = {
        # base path, that will be used to resolve files and exclude
        basePath: '',


        # frameworks to use
        frameworks: ['mocha'],


        # list of files / patterns to load in the browser
        files: [ path.join(cwd,'_test/index.js') ],


        # list of preprocessors
        preprocessors: preprocessors,


        webpack: {
            devtool: 'inline-source-map', #just do inline source maps instead of the default
            resolve: webpackConfig.resolve,
            module:
                loaders: loaders
        },


        webpackMiddleware: {
            noInfo: true,
            stats: {
                colors: true
            }
        },


        # test results reporter to use
        # possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
        reporters: ['spec'],


        # web server port
        port: 9876,


        # enable / disable colors in the output (reporters and logs)
        colors: true,


        # level of logging
        # possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
        logLevel: config.LOG_INFO,


        # enable / disable watching file and executing tests whenever any file changes
        autoWatch: true,


        # Start these browsers, currently available:
        # - Chrome
        # - ChromeCanary
        # - Firefox
        # - Opera (has to be installed with `npm install karma-opera-launcher`)
        # - Safari (only Mac; has to be installed with `npm install karma-safari-launcher`)
        # - PhantomJS
        # - IE (only Windows; has to be installed with `npm install karma-ie-launcher`)
        browsers: ['Chrome'],


        # If browser does not capture in given timeout [ms], kill it
        captureTimeout: 60000,


        # Continuous Integration mode
        # if true, it capture browsers, run tests and exit
        singleRun: false,


        # List plugins explicitly, since autoloading karma-webpack
        # won't work here
        plugins: [
            require("karma-webpack"),
            require("karma-mocha"),
            require("karma-spec-reporter"),
            require("karma-chrome-launcher"),
            require("karma-sourcemap-loader"),
            #require("../")
        ]
    }

    config.set(settings);
