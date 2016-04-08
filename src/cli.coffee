program = require('commander')
program.on '--help', ->
    console.log '  Usage:'
    console.log()
    console.log '    $', 'webpack-tool run server', '启动测试服务器'
    console.log '    $', 'webpack-tool run build', ' 生成最终构建文件'
    console.log()
    return
program.parse process.argv
task = program.args[0]
if !task
    program.help()
else
    gulp = require('gulp')
    require './gulpfile'
    gulp.start task
