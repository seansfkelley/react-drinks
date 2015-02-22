# @cjsx React.DOM

React = require 'react'

FluxMixin       = require './FluxMixin'
AppDispatcher   = require './AppDispatcher'
{ RecipeStore } = require './stores'

TabbedView = require './TabbedView'

RecipeListItem = React.createClass {
  render : ->
    <div className='recipe-list-item' onTouchTap={@_openRecipe}>
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

AlphabeticalRecipeList = React.createClass {
  mixins : [
    FluxMixin RecipeStore, 'alphabeticalRecipes'
  ]

  render : ->
    lastTitle = null
    recipeNames = _.chain @state.alphabeticalRecipes
      .map (recipe) ->
        firstLetter = recipe.name[0].toUpperCase()
        if firstLetter != lastTitle
          elements = [ <ListHeader title={firstLetter}/> ]
          lastTitle = firstLetter
        else
          elements = []

        return elements.concat [
          <RecipeListItem recipe={recipe} key={recipe.normalizedName}/>
        ]
      .flatten()
      .value()

    <div className='recipes-list alphabetical'>
      {recipeNames}
    </div>
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

tabs = [
  icon    : 'glass'
  title   : 'Browse All'
  content : <AlphabeticalRecipeList/>
,
  icon    : 'glass'
  title   : 'Mixable'
  content : <GroupedRecipeList/>
]

RecipeResultsPage = React.createClass {
  render : ->
    <TabbedView tabs={tabs}/>
}

module.exports = RecipeResultsPage
