redux = require 'redux'

rootReducer = redux.combineReducers {
  ui           : require './reducers/ui'
  filters      : require './reducers/filters'
  ingredients  : require './reducers/ingredients'
  recipes      : require './reducers/recipes'
  recipeEditor : require './reducers/recipeEditor'
}

createStore = redux.applyMiddleware(require('redux-thunk'))(redux.createStore)

module.exports = createStore rootReducer
