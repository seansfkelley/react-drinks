_               = require 'lodash'
React           = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

ReduxMixin        = require '../mixins/ReduxMixin'
DerivedValueMixin = require '../mixins/DerivedValueMixin'

SearchBar          = require '../components/SearchBar'
FixedHeaderFooter  = require '../components/FixedHeaderFooter'
List               = require '../components/List'

store            = require '../store'
utils            = require '../utils'
stylingConstants = require '../stylingConstants'
overlayViews     = require '../overlayViews'
Difficulty       = require '../Difficulty'

SwipableRecipeView = require './SwipableRecipeView'
RecipeListItem     = require './RecipeListItem'
RecipeListHeader   = require './RecipeListHeader'

RecipeList = React.createClass {
  displayName : 'RecipeList'

  propTypes :
    recipes                    : React.PropTypes.array.isRequired
    ingredientsByTag           : React.PropTypes.object.isRequired
    ingredientSplitsByRecipeId : React.PropTypes.object.isRequired

  mixins : [ PureRenderMixin ]

  render : ->
    recipeCount = _.chain @props.recipes
      .pluck 'recipes'
      .pluck 'length'
      .reduce ((sum, l) -> sum + l), 0
      .value()

    listNodes = []
    absoluteIndex = 0
    for { key, recipes } in @props.recipes
      if recipeCount > 6
        listNodes.push @_makeHeader(key, recipes)
      for r in recipes
        listNodes.push @_makeItem(key, r, absoluteIndex)
        absoluteIndex += 1

    <List className={List.ClassNames.HEADERED}>
      {listNodes}
    </List>

  _makeHeader : (groupKey, recipes) ->
    return <List.Header title={groupKey.toUpperCase()} key={'header-' + groupKey}/>

  _makeItem : (groupKey, r, absoluteIndex) ->
    missingIngredients = @props.ingredientSplitsByRecipeId[r.recipeId].missing
    if missingIngredients.length
      isMixable = false
      difficulty = Difficulty.getHardest(_.chain missingIngredients
        .pluck 'tag'
        .map (tag) => @props.ingredientsByTag[tag]
        .pluck 'difficulty'
        .value()
      )

    return <RecipeListItem
      difficulty={difficulty}
      isMixable={isMixable}
      recipeName={r.name}
      # TODO: This can acuse needless rerenders, especially when text-searching.
      # PureRenderMixin is bypassed since .bind() returns a new function every time.
      # Is there a way to always pass the same function and infer the index from the event?
      onTouchTap={SwipableRecipeView.showInModal.bind(null, {
        groupedRecipes             : @props.recipes
        ingredientsByTag           : @props.ingredientsByTag
        ingredientSplitsByRecipeId : @props.ingredientSplitsByRecipeId
        initialIndex               : absoluteIndex
      })}
      onDelete={if r.isCustom then @_deleteRecipe.bind(null, r.recipeId)}
      key={r.recipeId}
    />

  _deleteRecipe : (recipeId) ->
    store.dispatch {
      type : 'delete-recipe'
      recipeId
    }
}

RecipeListView = React.createClass {
  displayName : 'RecipeListView'

  propTypes : {}

  mixins : [
    ReduxMixin {
      filters     : [ 'recipeSearchTerm', 'baseLiquorFilter' ]
      ingredients : 'ingredientsByTag'
    }
    DerivedValueMixin [
      'filteredGroupedRecipes'
      'ingredientSplitsByRecipeId'
    ]
    PureRenderMixin
  ]

  render : ->
    list = <RecipeList
      recipes={@state.filteredGroupedRecipes}
      ingredientsByTag={@state.ingredientsByTag}
      ingredientSplitsByRecipeId={@state.ingredientSplitsByRecipeId}
    />

    <FixedHeaderFooter
      header={<RecipeListHeader/>}
      className='recipe-list-view'
      ref='container'
    >
      <SearchBar
        className='list-topper'
        initialValue={@state.recipeSearchTerm}
        placeholder='Name or ingredient...'
        onChange={@_onSearch}
        ref='search'
      />
      {list}
    </FixedHeaderFooter>

  componentDidUpdate : (prevProps, prevState) ->
    if not @refs.search.isFocused() and prevState.baseLiquorFilter != @state.baseLiquorFilter
      @_attemptScrollDown()

  _attemptScrollDown : _.debounce ->
    @refs.container.scrollTo stylingConstants.RECIPE_LIST_ITEM_HEIGHT - stylingConstants.RECIPE_LIST_HEADER_HEIGHT / 2

  _onSearch : (searchTerm) ->
    store.dispatch {
      type : 'set-recipe-search-term'
      searchTerm
    }

}

module.exports = RecipeListView
