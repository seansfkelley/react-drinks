Flux = require 'flux'

AppDispatcher = new Flux.Dispatcher

window.debug.AppDispatcher = AppDispatcher

module.exports = AppDispatcher
