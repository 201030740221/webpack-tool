fs = require('node-file')

module.exports = (output)->

    return ()->
        this.plugin 'done', (stats)->
            data =
                name: "frontend"
                version: "1.0.0"
                dependencies: {}
                commonDependencies: {}

            stats.compilation.chunks.map (chunk)->
                chunk.files.forEach (el)->
                    if chunk.name
                        moduleName = chunk.name.replace('-','/')

                        if moduleName == 'common'
                            if el.match(/\.([0-9a-z]+)$/)[0] == ".js" || el.match(/\.([0-9a-z]+)$/)[0] == ".css"
                                data.commonDependencies[ chunk.name + el.match(/\.([0-9a-z]+)$/)[0]] = el
                                data.commonDependencies[ chunk.name+ el.match(/\.([0-9a-z]+)$/)[0] + '.map'] = el+ '.map'
                        else
                            if el.match(/\.([0-9a-z]+)$/)[0] == ".js" || el.match(/\.([0-9a-z]+)$/)[0] == ".css"
                                data.dependencies[moduleName] = data.dependencies[moduleName] || {}
                                data.dependencies[moduleName][ chunk.name + el.match(/\.([0-9a-z]+)$/)[0]] = el
                                data.dependencies[moduleName][ chunk.name + el.match(/\.([0-9a-z]+)$/)[0] + '.map'] = el + '.map'

            fs.writeFileSync(output, JSON.stringify(data));
