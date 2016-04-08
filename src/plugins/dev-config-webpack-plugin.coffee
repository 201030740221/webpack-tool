# 生成项目常量设置
fs = require('node-file')
gutil = require('gulp-util')


module.exports = (output,data={})->
  env = gutil.env
  delete env._

  for item of data
    for _env of env
      if _env == item
        data[item] = env[_env]
        break

  content = "window.sipinConfig = " + JSON.stringify(data);
  fs.writeFileSync(output, content);
