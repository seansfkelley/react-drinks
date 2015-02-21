# @cjsx React.DOM

React = require 'react'

SegmentedView  = require './SegmentedView'
IngredientPage = require './IngredientPage'

segments = [
  title : 'Ingredients'
  content : <IngredientPage/>
,
  title : 'Recipes'
  content : <div/>
]

segmentedView = <SegmentedView segments={segments}/>

React.render segmentedView, document.body
