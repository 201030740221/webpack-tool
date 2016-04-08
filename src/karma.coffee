karmaServer = require('karma').Server
module.exports = (callback)->
    return new karmaServer({
        configFile: __dirname + '/configs/karma.conf',
        singleRun: false
    }, callback)
