livereload = require 'livereload'

livereload.createServer({
  exts       : [ 'cjsx', 'styl', 'json', 'jade' ]
  exclusions : [ 'node_modules/', '.compiler-cache/', 'livereload.coffee' ]
  debug      : true
})
.watch __dirname
