redux = require 'redux'

rootReducer = redux.combineReducers {
  ui             : require './ui'
  filters        : require './filters'
  ingredients    : require './ingredients'
  recipes        : require './recipes'
  editableRecipe : require './editaleRecipe'
}

createStore = redux.applyMiddleware(require('redux-thunk'))(redux.createStore)

module.exports = createStore rootReducer
