# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FluxMixin       = require './FluxMixin'
AppDispatcher   = require './AppDispatcher'
{ RecipeStore } = require './stores'

TabbedView        = require './TabbedView'
StickyHeaderMixin = require './StickyHeaderMixin'

RecipeListItem = React.createClass {
  render : ->
    <div className='recipe-list-item list-item' onTouchTap={@_openRecipe}>
      <div className='name'>{@props.recipe.name}</div>
    </div>

  _openRecipe : ->
    AppDispatcher.dispatch {
      type   : 'open-recipe'
      recipe : @props.recipe
    }
}

AlphabeticalRecipeList = React.createClass {
  mixins : [
    FluxMixin RecipeStore, 'alphabeticalRecipes'
    StickyHeaderMixin
  ]

  render : ->
    return @generateList {
      data        : @state.alphabeticalRecipes
      getTitle    : (recipe) -> recipe.name[0].toUpperCase()
      createChild : (recipe) -> <RecipeListItem recipe={recipe} key={recipe.normalizedName}/>
      classNames  : 'recipe-list alphabetical'
    }
}


GroupedRecipeList = React.createClass {
  mixins : [
    FluxMixin RecipeStore, 'groupedMixableRecipes'
    StickyHeaderMixin
  ]

  render : ->
    data = _.chain @state.groupedMixableRecipes
      .map ({ name, recipes }) ->
        _.map recipes, (r) -> [ name, r ]
      .flatten()
      .value()

    return @generateList {
      data        : data
      getTitle    : ([ name, recipe ]) -> name
      createChild : ([ name, recipe ]) -> <RecipeListItem recipe={recipe} key={recipe.normalizedName}/>
      classNames  : 'recipe-list grouped'
    }
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
