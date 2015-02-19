livereload = require 'livereload'

livereload.createServer({
  exts  : [ 'js', 'css' ]
  debug : true
})
.watch __dirname + '/.dist'
