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
#pkg.serverConfig.entry = pkg.serverConfig.entry.replace '__version__',pkg.version
pkg.buildConfig.output = pkg.buildConfig.output.replace '__version__',pkg.version

devConfig = {}
devConfig.name = pkg.name || "webpack-tool"
devConfig.version = pkg.version || "1.0.0"
devConfig.env = (pkg.projectConfig && pkg.projectConfig.env) || "development"
devConfig.config = pkg.projectConfig
devConfig.server = pkg.serverConfig
devConfig.webpack =
    base: pkg.buildConfig || {}

if pkg.developmentBuildConfig
    devConfig.webpack.development = pkg.developmentBuildConfig || {}
if pkg.qaBuildConfig
    devConfig.webpack.qa = pkg.qaBuildConfig || {}
if pkg.productionBuildConfig
    devConfig.webpack.production = pkg.productionBuildConfig || {}
devConfig.npmDependencies = pkg.devDependencies

module.exports = _.cloneDeep devConfig
