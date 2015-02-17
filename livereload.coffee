livereload = require 'livereload'

livereload.createServer({
  exts       : [ 'cjsx' ]
  exclusions : [ 'node_modules/', '.compiler-cache/' ]
  debug      : true
})
.watch __dirname
