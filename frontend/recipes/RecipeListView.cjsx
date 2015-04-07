# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FluxMixin     = require '../mixins/FluxMixin'
AppDispatcher = require '../AppDispatcher'

utils                    = require '../utils'
{ RecipeStore, UiStore } = require '../stores'

SwipableRecipeView = require './SwipableRecipeView'
EditableRecipeView = require './EditableRecipeView'
FavoritesList      = require '../favorites/FavoritesList'

SearchBar          = require '../components/SearchBar'
TitleBar           = require '../components/TitleBar'
FixedHeaderFooter  = require '../components/FixedHeaderFooter'
List               = require '../components/List'

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
    recipes : React.PropTypes.array.isRequired
    index   : React.PropTypes.number.isRequired

  render : ->
    <List.Item className='recipe-list-item' onTouchTap={@_openRecipe}>
      <div className='name'>{@_getRecipe().name}</div>
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
    <List.DeletableItem
      className='recipe-list-item incomplete'
      onDelete={@_delete}
      onTouchTap={@_openRecipe}
    >
      <div className='name'>{@_getRecipe().name}</div>
      {missingIngredients}
    </List.DeletableItem>

  _delete : ->
    console.log 'delete!'

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
  letter = RecipeListItem.getRecipeFor(child).name[0].toUpperCase()
  if NUMBER_REGEX.test letter
    return '#'
  else
    return letter

AlphabeticalRecipeList = React.createClass {
  displayName : 'AlphabeticalRecipeList'

  propTypes :
    recipes : React.PropTypes.array

  render : ->
    recipeNodes = _.map @props.recipes, (r, i) =>
      <RecipeListItem recipes={@props.recipes} index={i} key={r.normalizedName}/>

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
        return <IncompleteRecipeListItem recipes={orderedRecipes} index={i} key={r.normalizedName}/>
      else
        return <RecipeListItem recipes={orderedRecipes} index={i} key={r.normalizedName}/>

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
    FluxMixin RecipeStore, 'searchedAlphabeticalRecipes', 'searchedGroupedMixableRecipes'
  ]

  render : ->
    if @state.useIngredients
      list = <GroupedRecipeList recipes={@state.searchedGroupedMixableRecipes}/>
    else
      list = <AlphabeticalRecipeList recipes={@state.searchedAlphabeticalRecipes}/>

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
      @refs.container.scrollTo 44

  _onSearch : (searchTerm) ->
    AppDispatcher.dispatch {
      type : 'search-recipes'
      searchTerm
    }
}

module.exports = RecipeListView
