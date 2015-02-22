# @cjsx React.DOM

React = require 'react'

AppDispatcher           = require './AppDispatcher'
PaginatedView           = require './PaginatedView'
IngredientSelectionPage = require './IngredientSelectionPage'
RecipeResultsPage       = require './RecipeResultsPage'
RecipeView              = require './RecipeView'

page = [
  title : 'Ingredients'
  content : <IngredientSelectionPage/>
,
  title : 'Recipes'
  content : <RecipeResultsPage/>
]

paginatedView = <PaginatedView pages={page}/>

React.render paginatedView, document.body

AppDispatcher.register (payload) ->
  switch payload.type
    when 'open-recipe'
      React.render <RecipeView recipe={payload.recipe}/>, document.body
    when 'close-recipe'
      React.render paginatedView, document.body

  return true
