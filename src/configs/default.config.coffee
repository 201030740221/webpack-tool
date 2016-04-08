path = require('path')
version = '1.0.0'
_ = require 'lodash'

options =
    name: 'webpack-app' # 应用名称
    version: version # 版本号
    env: 'development' # 当前配置环境
    projectDir: path.join(__dirname) # 项目根目录
    cdnPath: '/' # CDN 地址
    server:
        devPort: 3210 # webpack-dev-server 端口
        webPort: 3200 # syncBrowser开发服务器端口
        #isProxy: true,                                      # 是否开启代理
        #proxyHost: "http://www.sipin.com",                  # 要代理的域名
        #proxyUrl: ["/api"],                                 # 要代理的链接
        entry: path.join(__dirname, './dist/1.0.0') # 入口文件
        publicPath: '/' # 服务器对应 CDN 地址
        liveload: true
    webpack:
        base:
            webpackDebug: false # 是否输出 webpack 损耗时间
            configFile: true # 是否输出配置文件
            commonFiles: true # 是否输出共同文件
            base64Limit: null # 是否开启把图片转换成base64,一般值为8192
            cdn: false # 是否开启 CDN
            cache: true
            debug: true
            recursive: true
            exportCss: true # 是否导出 CSS 文件
            exportHtml: true # 是否导出 HTML 文件
            hot: false
            entry: path.join(__dirname, './src/js/pages') # 文件（单入口）或者文件夹（多入口）
            output: path.join(__dirname, './dist', version) # 输出目录
            htmls: path.join(__dirname, './src/htmls') # 对应静态页面目录
            loaders: [] # 各种加载器
            resolve:
                root: path.resolve(__dirname)
                alias: {} # 设置别名
                extensions: [] # 加载时忽略后缀
                modulesDirectories: [ 'node_modules' ]
            externals: {} # 放置全局类库
        # 开发设置，覆盖 base 设置
        development:
            hash: false # 是否开启 hash
            uglify: false # 是否压缩
            sourceMap: true # 是否输入 source-map
            map: true # 是否输出 map.json
        # 测试设置
        qa:
            hash: true
            uglify: true
            sourceMap: true
            map: true
        # 上线设置
        production:
            hash: true
            uglify: true
            sourceMap: false
            map: true
        # 预编译设置
        prebuilt:
            hash: false
            uglify: true
            sourceMap: false
            map: false
    # config 应该可以通过命令行进行覆盖
    config: {}
module.exports = _.cloneDeep options
