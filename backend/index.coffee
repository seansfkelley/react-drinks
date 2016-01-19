log = require 'loglevel'

# Logging before all.
log.setLevel 'debug'

log.info "starting spirit guide with PORT=#{process.env.PORT} and NODE_ENV=#{process.env.NODE_ENV}"

_        = require 'lodash'
express  = require 'express'
notifier = require 'node-notifier'
assert   = require '../shared/tinyassert'

routes = require './routes'

start = ->
  # Express.
  app = express()

  # Templating.
  app.set 'view engine', 'jade'

  # Middleware.
  app.use require('body-parser').urlencoded({ extended : true })
  app.use require('morgan')('dev')
  app.use require('express-promise')()

  # Routes.
  app.use '/assets', express.static(__dirname + '/../.dist')
  log.info "attaching #{routes.length} routes"
  for { method, route, handler } in routes
    assert method
    assert route
    assert handler
    log.info "  #{method.toUpperCase()} #{route}"
    app[method](route, handler)

  # Go.
  port = process.env.PORT ? 8080
  app.listen port
  log.info "listening on localhost:#{port}"

  notifier.notify {
    title   : 'Server started'
    message : "localhost:#{port}"
  }

module.exports = { start }
