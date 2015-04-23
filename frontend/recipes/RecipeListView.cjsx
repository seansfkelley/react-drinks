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

  render : ->
    <TitleBar
      leftIcon='fa-star'
      leftIconOnTouchTap={@_openFavorites}
      title='Drinks'
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
    recipe     : React.PropTypes.object.isRequired
    mixability : React.PropTypes.number
    onTouchTap : React.PropTypes.func.isRequired

  render : ->
    if @props.mixability == 0
      mixabilityNode = <span className='mixability mixable'>
        <i className='fa fa-check'/>
      </span>
    else if @props.mixability > 0
      mixabilityNode = <span className='mixability near-mixable'>{@props.mixability}</span>

    <List.Item className='recipe-list-item' onTouchTap={@props.onTouchTap}>
      <span className='name'>{@props.recipe.name}</span>
      {mixabilityNode}
    </List.Item>
}

IncompleteRecipeListItem = React.createClass {
  displayName : 'IncompleteRecipeListItem'

  propTypes :
    recipe     : React.PropTypes.object.isRequired
    onTouchTap : React.PropTypes.func.isRequired

  render : ->
    missingIngredients = _.map @props.recipe.missing, (m) ->
      <div className='missing-ingredient' key={m.displayIngredient}>
        <span className='amount'>{utils.fractionify(m.displayAmount ? '')}</span>
        {' '}
        <span className='unit'>{m.displayUnit ? ''}</span>
        {' '}
        <span className='ingredient'>{m.displayIngredient}</span>
      </div>

    <List.Item className='recipe-list-item incomplete' onTouchTap={@props.onTouchTap}>
      <div className='name'>{@props.recipe.name}</div>
      {missingIngredients}
    </List.Item>
}

_generateRecipeOpener = (groupedRecipes, absoluteIndex) ->
  return ->
    recipes = _.chain groupedRecipes
      .pluck 'recipes'
      .flatten()
      .value()
    AppDispatcher.dispatch {
      type      : 'show-modal'
      component : <SwipableRecipeView recipes={recipes} index={absoluteIndex}/>
    }

AlphabeticalRecipeList = React.createClass {
  displayName : 'AlphabeticalRecipeList'

  propTypes :
    recipes    : React.PropTypes.array.isRequired
    mixability : React.PropTypes.object.isRequired

  render : ->
    headeredNodes = []
    absoluteIndex = 0
    for { key, recipes } in @props.recipes
      headeredNodes.push <List.Header title={key.toUpperCase()} key={'header-' + key}/>
      for r in recipes
        headeredNodes.push <RecipeListItem
          recipe={r}
          mixability={@props.mixability[r.recipeId]}
          onTouchTap={_generateRecipeOpener @props.recipes, absoluteIndex}
          key={r.recipeId}
        />
        absoluteIndex += 1

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
    recipes    : React.PropTypes.array.isRequired
    mixability : React.PropTypes.object.isRequired

  render : ->
    headeredNodes = []
    absoluteIndex = 0
    for { key, recipes } in @props.recipes
      headeredNodes.push <List.Header title={@_mixabilityToTitle key} key={'header-' + key}/>
      for r in recipes
        if r.missing.length
          listItem = <IncompleteRecipeListItem
            recipe={r}
            onTouchTap={_generateRecipeOpener @props.recipes, absoluteIndex}
            key={r.recipeId}
          />
        else
          listItem = <RecipeListItem
            recipe={r}
            onTouchTap={_generateRecipeOpener @props.recipes, absoluteIndex}
            key={r.recipeId}
          />

        headeredNodes.push listItem
        absoluteIndex += 1

    <List className={List.ClassNames.HEADERED}>
      {headeredNodes}
    </List>

  _mixabilityToTitle : (mixability) ->
    return switch mixability
      when 0 then 'Mixable Drinks'
      when 1 then 'With 1 More Ingredient'
      else "With #{mixability} More Ingredients"

}

RecipeListView = React.createClass {
  displayName : 'RecipeListView'

  propTypes : {}

  mixins : [
    FluxMixin UiStore, 'recipeSort'
    FluxMixin RecipeStore, 'searchedAlphabeticalRecipes', 'searchedMixableRecipes', 'mixabilityByRecipeId'
  ]

  render : ->
    list = switch @state.recipeSort
      when 'alphabetical'
        <AlphabeticalRecipeList
          recipes={@state.searchedAlphabeticalRecipes}
          mixability={@state.mixabilityByRecipeId}
        />
      when 'mixable'
        <GroupedRecipeList
          recipes={@state.searchedMixableRecipes}
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
