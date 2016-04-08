path = require 'path'
cwd = process.cwd()
pkg = require path.join(cwd, 'package.json')
_ = require 'lodash'

extend = (object, properties) ->
    for key, val of properties
        object[key] = val
    object

# 开发版配置
try
    localConfig = require path.join(cwd, 'dev.conf.js');
    pkg = extend pkg,localConfig
catch error

# 处理配置
# pkg.serverConfig.entry = pkg.serverConfig.entry.replace '__version__',pkg.version
pkg.buildConfig.output = pkg.buildConfig.output.replace '__version__',pkg.version
pkg.buildConfig.jsPath = pkg.buildConfig.prebuiltJsPath
pkg.buildConfig.cssPath = pkg.buildConfig.prebuiltCssPath
pkg.buildConfig.htmlPath = pkg.buildConfig.prebuiltHtmlPath
pkg.buildConfig.configFile = false
pkg.buildConfig.commonFiles = false

devConfig = {}
devConfig.name = pkg.name || "webpack-tool"
devConfig.version = pkg.version || "1.0.0"
devConfig.env = "prebuilt"
devConfig.config = pkg.projectConfig
devConfig.server = pkg.serverConfig
devConfig.webpack =
    base: pkg.buildConfig || {}

devConfig.webpack.production = pkg.prebuiltConfig || {}
devConfig.npmDependencies = pkg.devDependencies

module.exports = _.cloneDeep devConfig
