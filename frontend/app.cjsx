# @cjsx React.DOM

React = require 'react'

AppDispatcher           = require './AppDispatcher'
PaginatedView           = require './PaginatedView'
IngredientSelectionPage = require './IngredientSelectionPage'
RecipeResultsPage       = require './RecipeResultsPage'
RecipeView              = require './RecipeView'

NewRecipePage = require './NewRecipePage'

appRootElement = document.querySelector '#app-root'

React.render <NewRecipePage/>, appRootElement

return

page = [
  title : 'Ingredients'
  content : <IngredientSelectionPage/>
,
  title : 'Recipes'
  content : <RecipeResultsPage/>
]

paginatedView = <PaginatedView pages={page}/>

React.render paginatedView, appRootElement

AppDispatcher.register (payload) ->
  switch payload.type
    when 'open-recipe'
      React.render <RecipeView recipe={payload.recipe}/>, appRootElement
    when 'close-recipe'
      React.render paginatedView, appRootElement

  return true
