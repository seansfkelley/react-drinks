redux = require 'redux'

rootReducer = redux.combineReducers {
  ui             : require './substores/ui'
  filters        : require './substores/filters'
  ingredients    : require './substores/ingredients'
  recipes        : require './substores/recipes'
  editableRecipe : require './substores/editableRecipe'
}

createStore = redux.applyMiddleware(require('redux-thunk'))(redux.createStore)

module.exports = createStore rootReducer
