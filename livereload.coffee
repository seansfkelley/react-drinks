livereload = require 'livereload'

server = livereload.createServer({
  exts  : [ 'js', 'css', 'jade' ]
  debug : true
})

server.watch __dirname + '/.dist'
server.watch __dirname + '/views'
