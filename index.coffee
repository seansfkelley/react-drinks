_       = require 'lodash'
express = require 'express'

routes = require './routes'

# Express.
app = express()

# Templating.
app.set 'view engine', 'jade'

# Routes.
app.use '/', express.static(__dirname)
app.use '/', express.static(__dirname + '/.dist')
for { method, route, handler } in routes
  app[method ? 'get'](route, handler)

# Go.
port = process.env.PORT ? 8080
app.listen port
console.log "listening on localhost:#{port}"
