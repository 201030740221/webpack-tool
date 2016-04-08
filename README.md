基于 webpack 的构建工具，依赖 webpack 的 loaders 与 plugins 作为静态资源管理与构建。

### 依赖
基础依赖：
```
"gulp": "^3.8.11",
"gulp-util": "^3.0.4",
"object-assign": "^3.0.0",
"webpack-tool": "git+ssh://git@git:7999/wilson/webpack-tool.git#master"
```

### 构建命令
依然使用 gulp 驱动 webpack 打包，命令缩减为两个：

#### gulp build

默认每一个项目都有一个 `config.js`，存放需要经常配置的配置项。全局曝露`sipinConfig`，供脚本引用。
前端同学可以修改 `buildConfig.js` 里的 `config` 字段，建立默认的配置项。
通过命令行修改项目配置，使用方法如下：
```
--env production --websocket ws://push.sipin.test2
```

#### gulp server
启动前端预览服务器

### 配置文件
前端同学通过 `buildConfig.js` 统一管理项目的构建配置，对应个人自定义的配置，则可以在项目`buildConfig.js` 同目录新建一个 `devConfig.js`。
`devConfig.js` 里的配置优先于 `buildConfig.js` 的配置。



比较完整的配置如下：
```javascipt
var path = require('path');
var version = "1.0.0";
var env = "development";
var alias = require('./webpack.alias.js');
var assign = require('object-assign');
var devConfig = {};

try {
    devConfig = require('./devConfig.js');
    version = devConfig.version;
    env = devConfig.env;
}catch(e){
    console.log("自定义配置文件不存在");
}

module.exports = assign({
    name: "webpack-app",                                 // 应用名称
    version: version,                                    // 版本号
    env: env,                                            // 当前配置环境
    projectDir: path.join(__dirname),                    // 项目根目录
    cdnPath:'/',                                         // CDN 地址
    server: {
        devPort: 3210,                                   // webpack-dev-server 端口
        webPort: 3200,                                   // syncBrowser开发服务器端口
        entry: path.join(__dirname, "./dist", version),  // 入口文件
        publicPath: '/'                                  // 服务器对应 CDN 地址
    },
    webpack: {
        // 基础设置
        base: {
            cdn: false,                                   // 是否开启 CDN
            exportCss: true,                              // 是否导出 CSS 文件
            exportHtml: true,                             // 是否导出 HTML 文件
            entry: path.join(__dirname, './src/js/pages'),         // 文件（单入口）或者文件夹（多入口）
            output: path.join(__dirname, "./dist", version ),      // 输出目录
            htmlPath: path.join(__dirname, './src/html'),            // 对应静态页面目录
            cssPath: path.join(__dirname, './src/css/pages'),            // 对应静态页面目录
            loaders: ['cjsx','coffee','hbs','jsx','es6','css','styl','fonts','images','html','ico'],   // 各种加载器
            resolve:{
                root: path.resolve(__dirname),
                alias: alias,   // 设置别名
                extensions: ['', '.js', '.jsx', '.cjsx', '.coffee'],  // 加载时忽略后缀
                modulesDirectories: ["node_modules"]
            },
            externals:{  // 放置全局类库
                "jquery": "jQuery",
                "$": "jQuery",
                "React": "React"
            }
        },
        // 开发设置，覆盖 base 设置
        development:{
            hash: true,       // 是否开启 hash
            uglify: false,    // 是否压缩
            sourceMap: true,  // 是否输入 source-map
            recursive: true,
            cache: true,
            debug: true,
            map: true          // 是否输出 map.json
        },
        // 测试设置，覆盖 base 设置
        qa:{
            hash: true,
            uglify: false,
            sourceMap: true,
            recursive: true,
            cache: true,
            debug: true,
            map: true
        },
        // 上线设置，覆盖 base 设置
        production: {
            hash: true,
            uglify: false,
            sourceMap: true,
            recursive: true,
            cache: true,
            debug: true,
            map: true
        }

    },
    // config 应该可以通过命令行进行覆盖
    config: {
        env: env,
        apiHost: 'http://api.m.sipin.com',
        websocket: 'ws://push.sipin.test2'
    }
},devConfig);

```
