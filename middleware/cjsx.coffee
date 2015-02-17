_      = require 'lodash'
fs     = require 'fs'
path   = require 'path'
url    = require 'url'
mkdirp = require 'mkdirp'
debug  = require('debug') 'connect-coffee-script'

coffeeScript         = require 'coffee-script'
coffeeReactTransform = require 'coffee-react-transform'

module.exports = (options = {}) ->
  if _.isString options
    options = { src : options }

  baseDir = options.baseDir or process.cwd()
  src = options.src
  if not src
    throw new Error 'CJSX middleware requires "src" directory'
  src = path.resolve baseDir, src

  dest = options.dest or src
  dest = path.resolve baseDir, dest

  return (req, res, next) ->
    if 'GET' isnt req.method and 'HEAD' isnt req.method
      return next()

    pathname = url.parse(req.url).pathname
    if not /\.js$/.test(pathname)
      next()
    else
      if options.prefix and 0 is pathname.indexOf options.prefix
        pathname = pathname.substring options.prefix.length
      jsPath = path.join dest, pathname
      cjsxPath = path.join src, pathname.replace '.js', '.cjsx'

      error = (err) ->
        arg = if err.code == 'ENOENT' then null else err
        return next arg

      compile = ->
        debug 'read %s', jsPath
        fs.readFile cjsxPath, 'utf8', (err, str) ->
          return error(err) if err
          # If `options` is passed to `coffeeScript.compile` (as it is in the
          # default `options.compile` function), `coffeeScript.compile` will
          # put `options.filename` in error messages. Set `options.filename`!
          _.extend options, {
            filename      : cjsxPath
            generatedFile : path.basename(pathname)
            sourceFiles   : [ path.basename(pathname, '.js') + '.cjsx' ]
          }

          try
            js = coffeeScript.compile coffeeReactTransform(str), options, cjsxPath
          catch err
            return next err

          debug 'render %s', cjsxPath

          mkdirp path.dirname(jsPath), 0o0700, (err) ->
            return error(err) if err
            fs.writeFile jsPath, js, 'utf8', (err) ->
              return error(error) if err
              next()

      if options.force
        return compile()

      fs.stat cjsxPath, (err, cjsxStats) ->
        return error(err) if err
        fs.stat jsPath, (err, jsStats) ->
          if err
            if err.code == 'ENOENT'
              debug 'not found %s', jsPath
              compile()
            else
              next err
          else
            if cjsxStats.mtime > jsStats.mtime
              debug 'modified %s', jsPath
              compile()
            else
              next()
