assign = require 'object-assign'
defaultConfig = require './default.config.js'
ExtractCssPlugin = require("../plugins/extract-css-webpack-plugin")
ExtractHtmlPlugin = require("../plugins/extract-html-webpack-plugin")
_ = require 'lodash'

module.exports = (opts)->
    # 获取对应环境的设置
    webpackConfig = assign {},defaultConfig.webpack.base, opts.webpack.base, if opts.webpack[opts.env] then opts.webpack[opts.env] else defaultConfig.webpack[opts.env];
    # 处理 loader
    loaders = []
    npmDependencies = []
    for _npmDependencie of opts.npmDependencies
        npmDependencies.push _npmDependencie

    # cjsx
    if npmDependencies.indexOf('cjsx-loader') != -1
        cjsx_loader =
            test: /\.cjsx$/,
            loaders: ['cjsx-loader'],
            exclude: /node_modules/

        if npmDependencies.indexOf('coffee-loader') != -1
            cjsx_loader.loaders.unshift 'coffee-loader'

        loaders.push cjsx_loader

    #css
    if npmDependencies.indexOf('css-loader') != -1

        if webpackConfig.exportCss and npmDependencies.indexOf('stylus-loader') == -1 and npmDependencies.indexOf('sass-loader') == -1 and npmDependencies.indexOf('less-loader') == -1

            css_loader =
                test: /\.css$/,
                loader: ExtractCssPlugin.extract("css-loader")

            if npmDependencies.indexOf('style-loader') != -1
                css_loader.loader = ExtractCssPlugin.extract("style-loader", "css-loader")

        else

            css_loader =
                test: /\.css$/,
                loaders: ["css-loader"]

            if npmDependencies.indexOf('style-loader') != -1
                css_loader.loaders.unshift 'style-loader'

        loaders.push css_loader

    # styl
    if npmDependencies.indexOf('stylus-loader') != -1

        if webpackConfig.exportCss

            styl_loader =
                test: /\.styl$/,
                loader: ExtractCssPlugin.extract("stylus-loader"),
                exclude: /node_modules/

            if npmDependencies.indexOf('css-loader') != -1 and npmDependencies.indexOf('style-loader') == -1
                styl_loader.loader = ExtractCssPlugin.extract("css-loader", "stylus-loader")

            if npmDependencies.indexOf('style-loader') != -1 and npmDependencies.indexOf('css-loader') == -1
                styl_loader.loader = ExtractCssPlugin.extract("style-loader", "stylus-loader")

            if npmDependencies.indexOf('style-loader') != -1 and npmDependencies.indexOf('css-loader') != -1
                styl_loader.loader = ExtractCssPlugin.extract("style-loader", "css-loader!stylus-loader")

        else

            styl_loader =
                test: /\.styl$/,
                loaders: ["stylus-loader"],
                exclude: /node_modules/

            if npmDependencies.indexOf('css-loader') != -1
                styl_loader.loaders.unshift 'css-loader'

            if npmDependencies.indexOf('style-loader') != -1
                styl_loader.loaders.unshift 'style-loader'

        loaders.push styl_loader


    # sass
    if npmDependencies.indexOf('sass-loader') != -1

        if webpackConfig.exportCss

            sass_loader =
                test: /\.scss$/,
                loader: ExtractCssPlugin.extract("sass-loader"),
                exclude: /node_modules/

            if npmDependencies.indexOf('css-loader') != -1 and npmDependencies.indexOf('style-loader') == -1
                sass_loader.loader = ExtractCssPlugin.extract("css-loader", "sass-loader")

            if npmDependencies.indexOf('style-loader') != -1 and npmDependencies.indexOf('css-loader') == -1
                sass_loader.loader = ExtractCssPlugin.extract("style-loader", "sass-loader")

            if npmDependencies.indexOf('style-loader') != -1 and npmDependencies.indexOf('css-loader') != -1
                sass_loader.loader = ExtractCssPlugin.extract("style-loader", "css-loader!sass-loader")

        else

            sass_loader =
                test: /\.scss$/,
                loaders: ["sass-loader"],
                exclude: /node_modules/

            if npmDependencies.indexOf('css-loader') != -1
                sass_loader.loaders.unshift 'css-loader'

            if npmDependencies.indexOf('style-loader') != -1
                sass_loader.loaders.unshift 'style-loader'

        loaders.push sass_loader

    # less
    if npmDependencies.indexOf('less-loader') != -1

        if webpackConfig.exportCss

            less_loader =
                test: /\.less$/,
                loader: ExtractCssPlugin.extract("less-loader"),
                exclude: /node_modules/

            if npmDependencies.indexOf('css-loader') != -1 and npmDependencies.indexOf('style-loader') == -1
                less_loader.loader = ExtractCssPlugin.extract("css-loader", "less-loader")

            if npmDependencies.indexOf('style-loader') != -1 and npmDependencies.indexOf('css-loader') == -1
                less_loader.loader = ExtractCssPlugin.extract("style-loader", "less-loader")

            if npmDependencies.indexOf('style-loader') != -1 and npmDependencies.indexOf('css-loader') != -1
                less_loader.loader = ExtractCssPlugin.extract("style-loader", "css-loader!less-loader")

        else

            less_loader =
                test: /\.less$/,
                loaders: ["less-loader"],
                exclude: /node_modules/

            if npmDependencies.indexOf('css-loader') != -1
                less_loader.loaders.unshift 'css-loader'

            if npmDependencies.indexOf('style-loader') != -1
                less_loader.loaders.unshift 'style-loader'

        loaders.push less_loader


    # html
    if npmDependencies.indexOf('html-loader') != -1

        if webpackConfig.exportHtml
            loaders.push
                test: /\.html$/,
                loader: ExtractHtmlPlugin.extract("html-loader"),
                exclude: /node_modules/
        else
            loaders.push
                test: /\.html$/,
                loader: "html-loader",
                exclude: /node_modules/

    # url-loader
    if npmDependencies.indexOf('url-loader') != -1

        # 图片
        limit = if webpackConfig.base64Limit then 'limit=' + webpackConfig.base64Limit + '&' else ''
        imagesName = if webpackConfig.hash then "images/[hash].[ext]" else "images/[ext]"
        loaders.push
            test: /\.(png|jpg|gif)$/,
            loader: 'url-loader?' + limit + 'name='+imagesName,
            exclude: /node_modules/

        # 字体图标
        fontsName = if webpackConfig.hash then "fonts/[hash].[ext]" else "fonts/[ext]"
        loaders.push
            test: /\.(otf|eot|svg|ttf|woff)$/,
            loader: 'url-loader?' + limit + 'name='+fontsName,
            exclude: /node_modules/

    # es6
    if npmDependencies.indexOf('babel-loader') != -1
        loaders.push
            test: /\.(js|jsx)$/,
            loader: "babel-loader",
            exclude: /node_modules/

    # coffee
    if npmDependencies.indexOf('coffee-loader') != -1
        loaders.push
            test: /\.coffee$/,
            loader: "coffee-loader",
            exclude: /node_modules/

    # json
    if npmDependencies.indexOf('json-loader') != -1
        loaders.push
            test: /\.json$/,
            loader: "json-loader",
            exclude: /node_modules/

    # handlebars
    if npmDependencies.indexOf('handlebars-loader') != -1
        loaders.push
            test: /\.hbs$/,
            loader: "handlebars-loader?helperDirs[]=" + __dirname + "/handlebar-helpers",
            exclude: /node_modules/

    # react-templates-loader
    if npmDependencies.indexOf('react-templates-loader') != -1
        loaders.push
            test: /\.rt$/
            loader: "react-templates-loader"
            exclude: /node_modules/

    # react-templates-loader
    if npmDependencies.indexOf('static-loader') != -1
        iconName = if webpackConfig.hash then "images/[hash].[ext]" else "images/[ext]"
        loaders.push
            test: /\.ico$/
            loader: "static-loader?output="+iconName
            exclude: /node_modules/


    _.cloneDeep loaders
