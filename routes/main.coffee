method  = 'get'
route   = '/'
handler = (req, res) ->
  res.render 'main'

module.exports = { method, route, handler }
