# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FluxMixin = require '../mixins/FluxMixin'

SearchBar          = require '../components/SearchBar'
TitleBar           = require '../components/TitleBar'
FixedHeaderFooter  = require '../components/FixedHeaderFooter'
List               = require '../components/List'

AppDispatcher            = require '../AppDispatcher'
utils                    = require '../utils'
stylingConstants         = require '../stylingConstants'
{ RecipeStore, UiStore } = require '../stores'

SwipableRecipeView = require './SwipableRecipeView'
EditableRecipeView = require './EditableRecipeView'
FavoritesList      = require '../favorites/FavoritesList'

RecipeListHeader = React.createClass {
  displayName : 'RecipeListHeader'

  propTypes : {}

  mixins : [
    FluxMixin UiStore, 'useIngredients'
  ]

  render : ->
    if @state.useIngredients
      title = 'Mixable Drinks'
    else
      title = 'All Drinks'

    <TitleBar
      leftIcon='fa-star'
      leftIconOnTouchTap={@_openFavorites}
      title={title}
      rightIcon='fa-plus'
      rightIconOnTouchTap={@_newRecipe}
    />

  _newRecipe : ->
    AppDispatcher.dispatch {
      type      : 'show-modal'
      component : <EditableRecipeView/>
    }

  _openFavorites : ->
    AppDispatcher.dispatch {
      type      : 'show-pushover'
      component : <FavoritesList/>
    }
}

RecipeListItem = React.createClass {
  displayName : 'RecipeListItem'

  propTypes :
    name       : React.PropTypes.string.isRequired
    mixability : React.PropTypes.number.isRequired
    onTouchTap : React.PropTypes.func.isRequired

  render : ->
    if @props.mixability == 0
      mixabilityNode = <span className='mixability mixable'>
        <i className='fa fa-check'/>
      </span>
    else if @props.mixability > 0
      mixabilityNode = <span className='mixability near-mixable'>{@props.mixability}</span>

    <List.Item className='recipe-list-item' onTouchTap={@props.onTouchTap}>
      <span className='name'>{@props.name}</span>
      {mixabilityNode}
    </List.Item>
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
    <List.Item
      className='recipe-list-item incomplete'
      onTouchTap={@_openRecipe}
    >
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

NUMBER_REGEX = /[0-9]/

_recipeListItemTitleExtractor = (child) ->
  letter = child.props.name[0].toUpperCase()
  if NUMBER_REGEX.test letter
    return '#'
  else
    return letter

AlphabeticalRecipeList = React.createClass {
  displayName : 'AlphabeticalRecipeList'

  propTypes :
    recipes    : React.PropTypes.array.isRequired
    mixability : React.PropTypes.object.isRequired

  render : ->
    recipeNodes = _.map @props.recipes, (r, i) =>
      <RecipeListItem
        name={r.name}
        mixability={@props.mixability[r.recipeId]}
        onTouchTap={_.partial @_openRecipeByIndex, i}
        key={r.recipeId}
      />

    headeredNodes = List.headerify {
      nodes             : recipeNodes
      computeHeaderData : (node, i) ->
        title = _recipeListItemTitleExtractor node
        return {
          title
          key : 'header-' + title
        }
    }

    <List className={List.ClassNames.HEADERED}>
      {headeredNodes}
    </List>

  _openRecipeByIndex : (i) ->
    AppDispatcher.dispatch {
      type      : 'show-modal'
      component : <SwipableRecipeView recipes={@props.recipes} index={i}/>
    }
}

EmptyListView = React.createClass {
  displayName : 'EmptyListView'

  propTypes : {}

  render : ->
    <div className='empty-list-text'>
      No drinks?
      <br/>
      Try adding some ingredients!
    </div>
}

GroupedRecipeList = React.createClass {
  displayName : 'GroupedRecipeList'

  propTypes :
    recipes : React.PropTypes.array

  render : ->
    # This whole munging of the group business is kinda gross.
    groupRecipePairs = _.chain @props.recipes
      .map ({ name, recipes }) ->
        _.map recipes, (r) -> [ name, r ]
      .flatten()
      .value()

    orderedRecipes = _.pluck groupRecipePairs, '1'

    recipeNodes = _.map groupRecipePairs, ([ _, r ], i) =>
      if r.missing.length
        return <IncompleteRecipeListItem recipes={orderedRecipes} index={i} key={r.recipeId}/>
      else
        return <RecipeListItem recipes={orderedRecipes} index={i} key={r.recipeId}/>

    headeredNodes = List.headerify {
      nodes             : recipeNodes
      computeHeaderData : (node, i) ->
        title = groupRecipePairs[node.props.index][0]
        return {
          title
          key : 'header-' + title
        }
    }

    <List className={List.ClassNames.HEADERED} emptyView={<EmptyListView/>}>
      {headeredNodes}
    </List>
}

RecipeListView = React.createClass {
  displayName : 'RecipeListView'

  propTypes : {}

  mixins : [
    FluxMixin UiStore, 'useIngredients'
    FluxMixin RecipeStore, 'searchedAlphabeticalRecipes', 'searchedGroupedMixableRecipes', 'mixabilityByRecipeId'
  ]

  render : ->
    if @state.useIngredients
      list = <GroupedRecipeList recipes={@state.searchedGroupedMixableRecipes}/>
    else
      list = <AlphabeticalRecipeList
        recipes={@state.searchedAlphabeticalRecipes}
        mixability={@state.mixabilityByRecipeId}
      />

    <FixedHeaderFooter
      header={<RecipeListHeader/>}
      className='recipe-list-view'
      ref='container'
    >
      <SearchBar
        className='list-topper'
        placeholder='Name or ingredient...'
        onChange={@_onSearch}
        ref='search'
      />
      {list}
    </FixedHeaderFooter>

  componentDidUpdate : ->
    if not @refs.search.isFocused()
      @refs.container.scrollTo stylingConstants.RECIPE_LIST_ITEM_HEIGHT

  _onSearch : (searchTerm) ->
    AppDispatcher.dispatch {
      type : 'search-recipes'
      searchTerm
    }
}

module.exports = RecipeListView
