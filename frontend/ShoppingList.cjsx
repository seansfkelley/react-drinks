# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FluxMixin     = require './FluxMixin'
AppDispatcher = require './AppDispatcher'

{ RecipeStore, UiStore } = require './stores'

SearchBar         = require './SearchBar'
RecipeView        = require './RecipeView'
StickyHeaderMixin = require './StickyHeaderMixin'
utils             = require './utils'

HeaderWithSearch = require './HeaderWithSearch'

ShoppingListHeader = React.createClass {
  mixins : [
    FluxMixin UiStore, 'useIngredients'
  ]

  render : ->
    <HeaderWithSearch
      leftIcon='fa-times-circle'
      leftIconOnTouchTap={@_hideShoppingList}
      title='Shopping List'
      onSearch={@_setSearchTerm}
    />

  _hideShoppingList : ->
    AppDispatcher.dispatch {
      type : 'hide-flyup'
    }

  # In the future, this should pop up a loader and then throttle the number of filters performed.
  _setSearchTerm : (searchTerm) ->
    AppDispatcher.dispatch {
      type : 'search-recipes'
      searchTerm
    }
}

IncompleteRecipeListItem = React.createClass {
  render : ->
    missingIngredients = _.map @props.recipe.missing, (m) ->
      return <div className='missing-ingredient' key={m.displayIngredient}>
        <span className='amount'>{utils.fractionify(m.displayAmount ? '')}</span>
        {' '}
        <span className='unit'>{m.displayUnit ? ''}</span>
        {' '}
        <span className='ingredient'>{m.displayIngredient}</span>
      </div>
    <div className='incomplete-recipe-list-item list-item' onTouchTap={@_openRecipe}>
      <div className='name'>{@props.recipe.name}</div>
      {missingIngredients}
    </div>

  _openRecipe : ->
    AppDispatcher.dispatch {
      type      : 'show-modal'
      component : <RecipeView recipe={@props.recipe}/>
    }
}

ShoppingList = React.createClass {
  mixins : [
    FluxMixin RecipeStore, 'searchedGroupedMixableRecipes'
    StickyHeaderMixin
  ]

  render : ->
    data = _.chain @state.searchedGroupedMixableRecipes
      .filter ({ missing }) -> missing > 0
      .map ({ name, recipes }) ->
        _.map recipes, (r) -> [ name, r ]
      .flatten()
      .value()

    return @generateList {
      data        : data
      getTitle    : ([ name, recipe ]) -> name
      createChild : ([ name, recipe ]) -> <IncompleteRecipeListItem recipe={recipe} key={recipe.normalizedName}/>
      classNames  : 'shopping-list grouped'
    }
}

ShoppingListView = React.createClass {
  render : ->
    <div className='shopping-list-view'>
      <div className='fixed-header-bar'>
        <ShoppingListHeader/>
      </div>
      <div className='fixed-content-pane'>
        <ShoppingList/>
      </div>
    </div>
}

module.exports = ShoppingListView
