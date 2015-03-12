# @cjsx React.DOM

React = require 'react'

FixedHeaderFooter = require './components/FixedHeaderFooter'
RecipeListView    = require './recipes/RecipeListView'
IngredientsFooter = require './ingredients/IngredientsFooter'

App = React.createClass {
  render : ->
    <FixedHeaderFooter
      footer={<IngredientsFooter/>}
    >
      <RecipeListView/>
    </FixedHeaderFooter>
}

module.exports = App
