_       = require 'lodash'
express = require 'express'
log     = require 'loglevel'
routes  = require './routes'

# Logging.
log.setLevel 'info'

# Express.
app = express()

# Templating.
app.set 'view engine', 'jade'

# Routes.
app.use '/', express.static(__dirname + '/.dist')
log.info "attaching #{routes.length} routes"
for { method, route, handler } in routes
  method ?= 'get'
  log.info "#{method} #{route}"
  app[method](route, handler)

# Go.
port = process.env.PORT ? 8080
app.listen port
log.info "listening on localhost:#{port}"
