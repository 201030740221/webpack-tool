path = require('path')
fs = require('fs')
webpack = require('webpack')
gutil = require('gulp-util')
assign = require 'object-assign'
ExtractCssPlugin = require("../plugins/extract-css-webpack-plugin")
ExtractHtmlPlugin = require("../plugins/extract-html-webpack-plugin")
ManifestWebpackPlugin = require('../plugins/manifest-webpack-plugin')
DevConfigWebpackPlugin = require('../plugins/dev-config-webpack-plugin')
getLoaders = require('../configs/getloaders')
cwd = process.cwd()

defaultConfig = require './default.config.js'

# TODO: css-sprites,图片压缩

module.exports = (opts,mode="web-mode")->

    # 处理 loader
    loaders = getLoaders(opts);

    serverPort = opts.server && opts.server.devPort

    env = gutil.env.env || opts.env

    # 获取对应环境的设置
    webpackConfig = assign {}, defaultConfig.webpack.base, opts.webpack.base, if opts.webpack[env] then opts.webpack[env] else defaultConfig.webpack[env];

    # 覆盖传进来的环境变量
    web_env = gutil.env
    delete web_env["_"];
    assign opts.config,web_env

    webpackConfig.output = path.join cwd, webpackConfig.output
    webpackConfig.jsPath = path.join cwd, webpackConfig.jsPath
    webpackConfig.cssPath = path.join cwd, webpackConfig.cssPath
    webpackConfig.htmlPath = path.join cwd, webpackConfig.htmlPath

    alias_objs = {}
    for _alias of webpackConfig.resolve.alias
        alias_objs[_alias] = path.join cwd, webpackConfig.resolve.alias[_alias]
    webpackConfig.resolve.alias = alias_objs

    entry = {};
    entryType = ['.js','.coffee','.cjsx','.jsx','.html','.styl','.scss','.less','.css']
    # 遍历入口文件
    readPageDir =(subDir)->

        dirs = subDir && subDir.fs;
        dirsPath = subDir && subDir.path;
        _ext = subDir && subDir.ext;

        sameName = false;

        dirs.forEach (item)->

            _filename = (subDir && subDir.filename) || item;
            name = (subDir && subDir.name) || item;


            #如果是目录
            if fs.statSync(dirsPath + '/' + item).isDirectory() and item.indexOf('_') != 0 # 忽略对应文件夹
                #获取目录里的脚本合并
                data =
                    name: item,
                    path: dirsPath + '/' + item,
                    fs: fs.readdirSync(dirsPath + '/' + item),
                    filename: (subDir && subDir.filename && subDir.filename + "-" + item) || item
                    ext: _ext

                readPageDir(data);

            else if item.indexOf('_') != 0 and !sameName # 忽略对应文件

                ext = path.extname(dirsPath + '/' + item)

                if entryType.indexOf(ext) != -1

                    devServerJs = [
                        "webpack-dev-server/client?http://0.0.0.0:"+ serverPort,
                        'webpack/hot/only-dev-server'
                        ]

                    # 如果存在同名js
                    if name == item.replace(ext, '')

                        # 删除之前的非同名记录
                        if entry[_filename]
                            entry[_filename] = entry[_filename].filter (_item,index)->
                                _item_ext = path.extname(_item)
                                if _ext == "js" and [".coffee",".js",".cjsx",".jsx"].indexOf(_item_ext) != -1
                                    return false
                                if _ext == "css" and [".styl",".css",".scss",".less"].indexOf(_item_ext) != -1
                                    return false
                                if _ext == "html" and [".html"].indexOf(_item_ext) != -1
                                    return false
                                return true
                        else
                            entry[_filename] = []

                        # JS 开发环境加入websocket
                        if env == "development" and ( !opts.server.liveload and opts.webpack.hot) and _ext == "js"
                            entry[_filename].concat devServerJs
                            entry[_filename].push dirsPath + '/' + item
                        else
                            # CSS 加入共有 CSS
                            if _ext=="css" and fs.existsSync webpackConfig.cssCommonPath
                                # 读取共公样式
                                entry[_filename].push webpackConfig.cssCommonPath
                                entry[_filename].push dirsPath + '/' + item
                            else
                                entry[_filename].push dirsPath + '/' + item;

                        sameName = true;

                    else
                        if entry[_filename]
                            entry[_filename] = entry[_filename]
                        else
                            if env == "development" and ( !opts.server.liveload and opts.webpack.hot) and _ext == "js"
                                entry[_filename] = devServerJs
                            else
                                entry[_filename] = []

                        entry[_filename].push(dirsPath + '/' + item);

    # 添加 CSS入口文件
    if webpackConfig.exportCss and fs.existsSync(webpackConfig.cssPath)
        readPageDir
            ext: "css"
            path: webpackConfig.cssPath,
            htmlPath: webpackConfig.htmlPath,
            cssPath: webpackConfig.cssPath,
            fs: fs.readdirSync(webpackConfig.cssPath)

    # 添加 HTML入口文件
    if webpackConfig.exportHtml and fs.existsSync(webpackConfig.htmlPath)
        readPageDir
            ext: "html"
            path: webpackConfig.htmlPath,
            htmlPath: webpackConfig.htmlPath,
            cssPath: webpackConfig.cssPath,
            fs: fs.readdirSync(webpackConfig.htmlPath)

    # 添加 JS入口文件
    if webpackConfig.jsPath and fs.existsSync(webpackConfig.jsPath)
        readPageDir
            ext: "js"
            path: webpackConfig.jsPath,
            htmlPath: webpackConfig.htmlPath,
            cssPath: webpackConfig.cssPath,
            fs: fs.readdirSync(webpackConfig.jsPath)

    # 插件
    plugins = []

    # 共同类
    if webpackConfig.commonFiles
        plugins.push new webpack.optimize.CommonsChunkPlugin
            chunks: entry,
            name: "common",
            minChunks: 2

    # 全局类库
    if webpackConfig.global
        plugins.push new webpack.ProvidePlugin webpackConfig.global

    if env == "development"
        plugins.push new webpack.DefinePlugin
            __DEV__: true # 开发模式
            __QA__: false # 测试模式
            __PRO__: false # 线上模式

    if env == "qa"
        plugins.push new webpack.DefinePlugin
            __DEV__: false # 开发模式
            __QA__: true # 测试模式
            __PRO__: false

    if env == "production"
        plugins.push new webpack.DefinePlugin
            "process.env":
                NODE_ENV: JSON.stringify("production")
            __DEV__: false
            __QA__: false # 测试模式
            __PRO__: true

        plugins.push new webpack.HotModuleReplacementPlugin()

    if webpackConfig.exportCss
        exportCssName = if webpackConfig.hash then "css/[name].[hash].css" else "css/[name].css"
        plugins.push new ExtractCssPlugin exportCssName

    if webpackConfig.exportHtml
        plugins.push new ExtractHtmlPlugin "[name].html",{
            chunksEntry: entry
        }

    if webpackConfig.uglify
        plugins.push new webpack.optimize.UglifyJsPlugin
            compress:
                warnings: false

    if webpackConfig.map and mode == "web-mode"
        plugins.push new ManifestWebpackPlugin path.join webpackConfig.output ,'map.json'

    # 常理设置
    if mode == "web-mode" and  webpackConfig.configFile
        DevConfigWebpackPlugin path.join(webpackConfig.output ,'config.js'), opts.config

    exportJSName = if webpackConfig.hash then "js/[name].[hash].js" else "js/[name].js"
    options =
        entry: entry
        recursive: !!(env == "production")
        cache: !!(env == "production")
        debug: !!(env == "production")
        output:
            path: webpackConfig.output
            filename: exportJSName
            publicPath: if webpackConfig.cdn then opts.cdnPath else opts.server.publicPath
            sourceMapFilename: "[file].map"
        resolveLoader:
            modulesDirectories: ['node_modules']
        plugins: plugins
        resolve:
            extensions: ['', '.js', '.jsx', '.cjsx', '.coffee']
        module:
            loaders: loaders
            noParse: []

    if webpackConfig.webpackDebug
        options = assign(options,{
            profile: true
            stats: {
                reasons: true,
                exclude: [],
                modules: true,
                colors: true,
            }
        });

    if webpackConfig.sourceMap
        options = assign(options,{
            devtool: "source-map"
        });


    options.resolve = webpackConfig.resolve
    options.externals = webpackConfig.externals

    addVendor = (name, path)->
        options.resolve.alias[name] = path
        options.module.noParse.push new RegExp '^' + name + '$'

    for vendor of webpackConfig.vendorlist
        vendorPath = webpackConfig.vendorlist[vendor]
        if !(/^(http?:)?\/\//.test path)
            vendorPath = path.join cwd, vendorPath

        addVendor vendor, vendorPath

    assign {},options
