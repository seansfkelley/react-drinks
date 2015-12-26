log = require 'loglevel'

# Logging before all.
log.setLevel 'debug'

_       = require 'lodash'
express = require 'express'
routes  = require './routes'

start = ->
  # Express.
  app = express()

  # Templating.
  app.set 'view engine', 'jade'

  # Middleware.
  app.use require('body-parser').urlencoded({ extended : true })
  app.use require('morgan')('dev')

  # Routes.
  app.use '/assets', express.static(__dirname + '/../.dist')
  log.info "attaching #{routes.length} routes"
  for { method, route, handler } in routes
    method ?= 'get'
    log.info "#{method} #{route}"
    app[method](route, handler)

  # Go.
  port = process.env.PORT ? 8080
  app.listen port
  log.info "listening on localhost:#{port}"

module.exports = { start }
