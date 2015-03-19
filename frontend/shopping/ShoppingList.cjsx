# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FluxMixin     = require '../mixins/FluxMixin'
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
      placeholder='Recipe or ingredient...'
    />

  _hideShoppingList : ->
    AppDispatcher.dispatch {
      type : 'hide-flyup'
    }
    # This might be more "semantic" if we clear the header, but this will do.
    @_setSearchTerm ''

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

    orderedRecipes = _.pluck groupRecipePairs, '1'

    recipeNodes = _.map groupRecipePairs, ([ _, r ], i) =>
      <IncompleteRecipeListItem recipes={orderedRecipes} index={i} key={r.normalizedName}/>

    headeredNodes = Lists.headerify {
      nodes : recipeNodes
      computeHeaderData : (node, i) ->
        title = groupRecipePairs[node.props.index][0]
        return {
          title
          key : 'header-' + title
        }
    }

    <Lists.List className={Lists.ClassNames.HEADERED}>
      {headeredNodes}
    </Lists.List>
}

ShoppingListView = React.createClass {
  displayName : 'ShoppingListView'

  render : ->
    <FixedHeaderFooter
      header={<ShoppingListHeader/>}
      className='shopping-list-view'
    >
      <ShoppingList/>
    </FixedHeaderFooter>
}

module.exports = ShoppingListView
