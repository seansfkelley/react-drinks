# @cjsx React.DOM

React = require 'react'

PaginatedView           = require './PaginatedView'
IngredientSelectionPage = require './IngredientSelectionPage'
RecipeResultsPage       = require './RecipeResultsPage'

page = [
  title : 'Ingredients'
  content : <IngredientSelectionPage/>
,
  title : 'Recipes'
  content : <RecipeResultsPage/>
]

paginatedView = <PaginatedView pages={page}/>

React.render paginatedView, document.body
