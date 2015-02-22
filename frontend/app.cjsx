# @cjsx React.DOM

React = require 'react'

PaginatedView  = require './PaginatedView'
IngredientPage = require './IngredientPage'
RecipePage     = require './RecipePage'

page = [
  title : 'Ingredients'
  content : <IngredientPage/>
,
  title : 'Recipes'
  content : <RecipePage/>
]

paginatedView = <PaginatedView pages={page}/>

React.render paginatedView, document.body
