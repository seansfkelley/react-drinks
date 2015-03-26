_       = require 'lodash'
express = require 'express'
log     = require 'loglevel'

# Logging.
log.setLevel 'info'

# Express.
app = express()

# Templating.
app.set 'view engine', 'jade'

# Routes.
app.use '/', express.static(__dirname + '/.dist')
for { method, route, handler } in require './routes'
  app[method ? 'get'](route, handler)

# Go.
port = process.env.PORT ? 8080
app.listen port
log.info "listening on localhost:#{port}"
