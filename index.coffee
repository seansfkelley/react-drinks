express = require 'express'
jade    = require 'jade'

routes = require './routes'

# Express.
app = express()

# Templating.
app.set 'view engine', 'jade'
app.set 'views', __dirname + '/templates'

# Routes.
app.use '/lib', express.static(__dirname + '/frontend-lib')

for { method, route, handler } in routes
  app[method ? 'get'](route, handler)

# Go.
app.listen 8080
