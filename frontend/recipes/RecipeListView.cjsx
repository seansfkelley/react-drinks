# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FluxMixin     = require '../mixins/FluxMixin'
AppDispatcher = require '../AppDispatcher'

{ RecipeStore, UiStore } = require '../stores'

FavoritesList      = require '../favorites/FavoritesList'
SwipableRecipeView = require '../recipes/SwipableRecipeView'
HeaderWithSearch   = require '../components/HeaderWithSearch'

FixedHeaderFooter = require '../components/FixedHeaderFooter'
Lists             = require '../components/Lists'

RecipeListHeader = React.createClass {
  displayName : 'RecipeListHeader'

  mixins : [
    FluxMixin UiStore, 'useIngredients'
  ]

  render : ->
    if @state.useIngredients
      title = 'Mixable Drinks'
    else
      title = 'All Drinks'

    <HeaderWithSearch
      leftIcon='fa-star'
      leftIconOnTouchTap={@_openFavorites}
      title={title}
      onSearch={@_setSearchTerm}
      placeholder='Name or ingredient...'
    />

  _openFavorites : ->
    AppDispatcher.dispatch {
      type      : 'show-pushover'
      component : <FavoritesList/>
    }

  # In the future, this should pop up a loader and then throttle the number of filters performed.
  _setSearchTerm : (searchTerm) ->
    AppDispatcher.dispatch {
      type : 'search-recipes'
      searchTerm
    }
}

RecipeListItem = React.createClass {
  displayName : 'RecipeListItem'

  render : ->
    <Lists.ListItem className= 'recipe-list-item' onTouchTap={@_openRecipe}>
      <div className='name'>{@_getRecipe().name}</div>
    </Lists.ListItem>

  _openRecipe : ->
    AppDispatcher.dispatch {
      type      : 'show-modal'
      component : <SwipableRecipeView recipes={@props.recipes} index={@props.index}/>
    }

  _getRecipe : ->
    return RecipeListItem.getRecipeFor @

  statics :
    getRecipeFor : (element) ->
      return element.props.recipes[element.props.index]
}

_recipeListItemTitleExtractor = (child) ->
  return RecipeListItem.getRecipeFor(child).name[0].toUpperCase()

AlphabeticalRecipeList = React.createClass {
  displayName : 'AlphabeticalRecipeList'

  mixins : [
    FluxMixin RecipeStore, 'searchedAlphabeticalRecipes'
  ]

  render : ->
    recipeNodes = _.map @state.searchedAlphabeticalRecipes, (r, i) =>
      <RecipeListItem recipes={@state.searchedAlphabeticalRecipes} index={i} key={r.normalizedName}/>

    headeredNodes = Lists.headerify {
      nodes             : recipeNodes
      computeHeaderData : (node, i) ->
        title = _recipeListItemTitleExtractor node
        return {
          title
          key : 'header-' + title
        }
    }

    <Lists.HeaderedList>
      {headeredNodes}
    </Lists.HeaderedList>
}

EmptyListView = React.createClass {
  render : ->
    <div className='empty-list-text'>
      No drinks?
      <br/>
      Try adding some ingredients!
    </div>
}

GroupedRecipeList = React.createClass {
  displayName : 'GroupedRecipeList'

  mixins : [
    FluxMixin RecipeStore, 'searchedGroupedMixableRecipes'
  ]

  render : ->
    # This whole munging of the group business is kinda gross.
    groupRecipePairs = _.chain @state.searchedGroupedMixableRecipes
      .map ({ name, recipes }) ->
        _.map recipes, (r) -> [ name, r ]
      .flatten()
      .value()

    titleExtractor = (child) ->
      return

    orderedRecipes = _.pluck groupRecipePairs, '1'

    recipeNodes = _.map groupRecipePairs, ([ _, r ], i) =>
      <RecipeListItem recipes={orderedRecipes} index={i} key={r.normalizedName}/>

    headeredNodes = Lists.headerify {
      nodes             : recipeNodes
      computeHeaderData : (node, i) ->
        title = groupRecipePairs[node.props.index][0]
        return {
          title
          key : 'header-' + title
        }
    }

    <Lists.HeaderedList emptyView={<EmptyListView/>}>
      {headeredNodes}
    </Lists.HeaderedList>
}

RecipeListView = React.createClass {
  displayName : 'RecipeListView'

  mixins : [
    FluxMixin UiStore, 'useIngredients'
  ]

  render : ->
    # There's no way rewrapping these elements in divs that give them the fixed classes is best practices.
    if @state.useIngredients
      list = <GroupedRecipeList/>
    else
      list = <AlphabeticalRecipeList/>

    <FixedHeaderFooter
      header={<RecipeListHeader/>}
    >
      {list}
    </FixedHeaderFooter>
}

module.exports = RecipeListView
