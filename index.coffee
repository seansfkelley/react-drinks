express             = require 'express'
connectCoffeescript = require 'connect-coffee-script'
connectCoffeeReact  = require './middleware/cjsx'

routes = require './routes'

# Express.
app = express()

# Templating.
app.set 'view engine', 'jade'
# app.engine 'cjsx', require('express-coffee-react-views').createEngine()
# app.set 'views', __dirname + '/views'

# Routes.
app.use '/', connectCoffeescript {
  src       : __dirname + '/frontend'
  dest      : __dirname + '/.compiler-cache/frontend'
  force     : true
  sourceMap : true
}
app.use '/', express.static(__dirname + '/.compiler-cache/frontend')

app.use '/', connectCoffeeReact {
  src       : __dirname + '/templates'
  dest      : __dirname + '/.compiler-cache/templates'
  force     : true
}
app.use '/', express.static(__dirname + '/.compiler-cache/templates')

app.use '/lib', express.static(__dirname + '/frontend-lib')

for { method, route, handler } in routes
  app[method ? 'get'](route, handler)

# Go.
app.listen 8080
console.log 'listening on localhost:8080'
