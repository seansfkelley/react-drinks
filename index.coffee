express             = require 'express'
connectCoffeescript = require 'connect-coffee-script'

routes = require './routes'

# Express.
app = express()

# Templating.
app.set 'view engine', 'cjsx'
app.engine 'cjsx', require('express-coffee-react-views').createEngine()
app.set 'views', __dirname + '/templates'

# Routes.
app.use '/', connectCoffeescript {
  src       : __dirname + '/frontend'
  dest      : __dirname + '/.compiler-cache'
  force     : true
  sourceMap : true
}
app.use '/', express.static(__dirname + '/.compiler-cache')

app.use '/lib', express.static(__dirname + '/frontend-lib')

for { method, route, handler } in routes
  app[method ? 'get'](route, handler)

# Go.
app.listen 8080
