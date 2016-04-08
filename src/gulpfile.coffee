path = require 'path'
webpackTool = require '../index'
gulp = require 'gulp'
gutil = require 'gulp-util'
sequence = require 'gulp-sequence'
del = require 'del'
devConfig = require './configs/dev.config'
prebuiltConfig = require './configs/prebuilt.config'
cwd = process.cwd()
pkg = require path.join cwd, 'package.json'
webpack = require("webpack")

################# 通用方法 #########################
useWebpack = (conf, callback)->
    webpackTool.compiler(conf).run (err, stats)->
        if (err)
            throw new gutil.PluginError('[webpack]', err);
        #gutil.log('[webpack:build]', stats.toString({ colors: true }));
        callback();

################# 细分任务 #########################

# 清空 dist
gulp.task "clean", ->
    del path.join(cwd,'/dist')


# 开发预览服务器 -- 组件模式
gulp.task "component", ['clean'], ()->
    webpackTool.server devConfig,"component-mode"

# 编译
gulp.task "webpack:js", (callback)->
    #console.log(1);
    webpackTool.compiler(devConfig).run (err, stats)->
        if (err)
            throw new gutil.PluginError('[webpack]', err);
        gutil.log('[webpack:build]', stats.toString({ colors: true }));
        callback();
    return

# 测试
gulp.task 'test', (callback)->
    webpackTool.karma(callback).start()

# 公用类库
gulp.task 'common:js', (callback)->
    webpack {
        entry:
            vendor: path.join( cwd , '/src/js/common/index.js')
        output:
            path: path.join( cwd , devConfig.webpack.base.output + '/js')
            publicPath: "/"
            filename: "[name].js"
        module:
            loaders: [
                { test: /\.(js|.jsx)$/,    loader: "babel-loader" },
                { test: /\.css$/,    loaders: ["style-loader","css-loader"] }
            ]
    }, (err, stats)->
        if(err)
            throw new gutil.PluginError("webpack", err);
        gutil.log "[common:js]", stats.toString()
        callback();


################# 构建流程 #########################

# [预编译任务]
gulp.task 'preCompile', ['webpack:js']

# [编译任务]
gulp.task 'postCompile', ->
    #console.log 2

# [编译后处理任务]
gulp.task 'afterCompile', ->
    #console.log 3

# [执行编译任务]
gulp.task 'release', ->
    gulp.start('preCompile','postCompile','afterCompile')

# [开发服务器预览]
gulp.task "server", ['clean','common:js','release'], ()->
    webpackTool.BsServer devConfig
    commonDir = path.join(cwd,'/src/js/common/**')
    gulp.watch(  commonDir, ['common:js']);
    gulp.watch( [path.join(cwd,'/src/**/*'),'!'+commonDir] , ['webpack:js']);

# [打包构建]
gulp.task "build", ['clean','common:js','release'], ->
    gutil.log "[build complete]"




module.exports = gulp;
