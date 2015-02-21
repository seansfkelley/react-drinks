# @cjsx React.DOM

React = require 'react'

PaginatedView  = require './PaginatedView'
IngredientPage = require './IngredientPage'

page = [
  title : 'Ingredients'
  content : <IngredientPage/>
,
  title : 'Recipes'
  content : <div/>
]

paginatedView = <PaginatedView pages={page}/>

React.render paginatedView, document.body
