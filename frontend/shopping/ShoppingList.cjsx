# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FluxMixin     = require '../mixins/FluxMixin'
AppDispatcher = require '../AppDispatcher'
utils         = require '../utils'

{ RecipeStore, UiStore } = require '../stores'

SwipableRecipeView = require '../recipes/SwipableRecipeView'
FixedHeaderFooter  = require '../components/FixedHeaderFooter'
List               = require '../components/List'
TitleBarWithSearch   = require '../components/TitleBarWithSearch'

ShoppingListHeader = React.createClass {
  displayName : 'ShoppingListHeader'

  propTypes : {}

  mixins : [
    FluxMixin UiStore, 'useIngredients'
  ]

  render : ->
    <TitleBarWithSearch
      leftIcon='fa-chevron-down'
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

  propTypes :
    recipes : React.PropTypes.array.isRequired
    index   : React.PropTypes.number.isRequired

  render : ->
    missingIngredients = _.map @_getRecipe().missing, (m) ->
      return <div className='missing-ingredient' key={m.displayIngredient}>
        <span className='amount'>{utils.fractionify(m.displayAmount ? '')}</span>
        {' '}
        <span className='unit'>{m.displayUnit ? ''}</span>
        {' '}
        <span className='ingredient'>{m.displayIngredient}</span>
      </div>
    <List.Item className='incomplete-recipe-list-item' onTouchTap={@_openRecipe}>
      <div className='name'>{@_getRecipe().name}</div>
      {missingIngredients}
    </List.Item>

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

  propTypes : {}

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

    headeredNodes = List.headerify {
      nodes : recipeNodes
      computeHeaderData : (node, i) ->
        title = groupRecipePairs[node.props.index][0]
        return {
          title
          key : 'header-' + title
        }
    }

    <List className={List.ClassNames.HEADERED}>
      {headeredNodes}
    </List>
}

ShoppingListView = React.createClass {
  displayName : 'ShoppingListView'

  propTypes : {}

  render : ->
    <FixedHeaderFooter
      header={<ShoppingListHeader/>}
      className='shopping-list-view'
    >
      <ShoppingList/>
    </FixedHeaderFooter>
}

module.exports = ShoppingListView
