# @cjsx React.DOM

React = require 'react'

FluxMixin       = require './FluxMixin'
AppDispatcher   = require './AppDispatcher'
{ RecipeStore } = require './stores'

RecipeListItem = React.createClass {
  render : ->
    <div className='recipe' onTouchTap={@_openRecipe}>
      <div className='name'>{@props.recipe.name}</div>
    </div>

  _openRecipe : ->
    AppDispatcher.dispatch {
      type           : 'open-recipe'
      normalizedName : @props.recipe.normalizedName
    }
}


ListHeader = React.createClass {
  render : ->
    <div className='list-header'>{@props.title}</div>
}

GroupedRecipeList = React.createClass {
  mixins : [
    FluxMixin RecipeStore, 'groupedMixableRecipes'
  ]

  render : ->
    recipeNodes = _.chain @state.groupedMixableRecipes
      .map ({ name, recipes }) ->
        return [
          <ListHeader title={name}/>
          _.map recipes, (recipe) ->
            <RecipeListItem recipe={recipe} key={recipe.normalizedName}/>
        ]
      .flatten()
      .value()

    <div className='recipe-list grouped'>
      {recipeNodes}
    </div>
}

RecipePage = React.createClass {
  render : ->
    <GroupedRecipeList/>
}

module.exports = RecipePage
