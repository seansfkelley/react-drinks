# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FluxMixin     = require '../FluxMixin'
AppDispatcher = require '../AppDispatcher'
utils         = require '../utils'

{ RecipeStore, UiStore } = require '../stores'

SwipableRecipeView = require '../recipes/SwipableRecipeView'
FixedHeaderFooter  = require '../components/FixedHeaderFooter'
Lists              = require '../components/Lists'
HeaderWithSearch   = require '../components/HeaderWithSearch'

ShoppingListHeader = React.createClass {
  displayName : 'ShoppingListHeader'

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
  displayName : 'IncompleteRecipeListItem'

  render : ->
    missingIngredients = _.map @_getRecipe().missing, (m) ->
      return <div className='missing-ingredient' key={m.displayIngredient}>
        <span className='amount'>{utils.fractionify(m.displayAmount ? '')}</span>
        {' '}
        <span className='unit'>{m.displayUnit ? ''}</span>
        {' '}
        <span className='ingredient'>{m.displayIngredient}</span>
      </div>
    <Lists.ListItem className='incomplete-recipe-list-item' onTouchTap={@_openRecipe}>
      <div className='name'>{@_getRecipe().name}</div>
      {missingIngredients}
    </Lists.ListItem>

  _openRecipe : ->
    AppDispatcher.dispatch {
      type      : 'show-modal'
      component : <SwipableRecipeView recipes={@props.recipes} index={@props.index}/>
    }

  _getRecipe : ->
    return IncompleteRecipeListItem.getRecipeFor @

  statics :
    getRecipeFor : (element) ->
      return element.props.recipes[element.props.index]
}

ShoppingList = React.createClass {
  displayName : 'ShoppingList'

  mixins : [
    FluxMixin RecipeStore, 'searchedGroupedMixableRecipes'
  ]

  render : ->
    groupRecipePairs = _.chain @state.searchedGroupedMixableRecipes
      .filter ({ missing }) -> missing > 0
      .map ({ name, recipes }) ->
        _.map recipes, (r) -> [ name, r ]
      .flatten()
      .value()

    titleExtractor = (child) ->
      return groupRecipePairs[child.props.index][0]

    orderedRecipes = _.pluck groupRecipePairs, '1'

    recipeNodes = _.map groupRecipePairs, ([ _, r ], i) =>
      <IncompleteRecipeListItem recipes={orderedRecipes} index={i} key={r.normalizedName}/>

    <Lists.HeaderedList titleExtractor={titleExtractor}>
      {recipeNodes}
    </Lists.HeaderedList>
}

ShoppingListView = React.createClass {
  displayName : 'ShoppingListView'

  render : ->
    <FixedHeaderFooter
      header={<ShoppingListHeader/>}
      classNames='shopping-list-view'
    >
      <ShoppingList/>
    </FixedHeaderFooter>
}

module.exports = ShoppingListView
