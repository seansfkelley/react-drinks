_               = require 'lodash'
React           = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

ReduxMixin        = require '../mixins/ReduxMixin'
DerivedValueMixin = require '../mixins/DerivedValueMixin'

SearchBar = require '../components/SearchBar'
List      = require '../components/List'

store            = require '../store'
utils            = require '../utils'
stylingConstants = require '../stylingConstants'
Difficulty       = require '../Difficulty'

SwipableRecipeView = require './SwipableRecipeView'
RecipeListItem     = require './RecipeListItem'
RecipeListHeader   = require './RecipeListHeader'

RecipeList = React.createClass {
  displayName : 'RecipeList'

  propTypes :
    recipes                    : React.PropTypes.array.isRequired
    ingredientsByTag           : React.PropTypes.object.isRequired
    favoritedRecipeIds         : React.PropTypes.array.isRequired
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

    # TODO: This can cause needless rerenders, especially when text-searching.
    # PureRenderMixin is bypassed since .bind() returns a new function every time.
    # Is there a way to always pass the same function and infer the index from the event?
    return <RecipeListItem
      difficulty={difficulty}
      isMixable={isMixable}
      recipeName={r.name}
      onTouchTap={@_showRecipeViewer.bind this, absoluteIndex}
      onDelete={if r.isCustom then @_deleteRecipe.bind(null, r.recipeId)}
      key={r.recipeId}
    />

  _showRecipeViewer : (index) ->
    recipeIds = _.chain @props.recipes
      .pluck 'recipes'
      .flatten()
      .pluck 'recipeId'
      .value()

    store.dispatch {
      type : 'show-recipe-viewer'
      recipeIds
      index
    }

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
      ui          : 'favoritedRecipeIds'
    }
    DerivedValueMixin [
      'filteredGroupedRecipes'
      'ingredientSplitsByRecipeId'
    ]
    PureRenderMixin
  ]

  render : ->
    <div className='recipe-list-view fixed-header-footer'>
      <RecipeListHeader/>
      <div className='fixed-content-pane' ref='content'>
        <SearchBar
          className='list-topper'
          initialValue={@state.recipeSearchTerm}
          placeholder='Name or ingredient...'
          onChange={@_onSearch}
          ref='search'
        />
        <RecipeList
          recipes={@state.filteredGroupedRecipes}
          ingredientsByTag={@state.ingredientsByTag}
          ingredientSplitsByRecipeId={@state.ingredientSplitsByRecipeId}
          favoritedRecipeIds={@state.favoritedRecipeIds}
        />
      </div>
    </div>

  componentDidMount : ->
    @_attemptScrollDown()

  componentDidUpdate : (prevProps, prevState) ->
    if not @refs.search.isFocused() and prevState.baseLiquorFilter != @state.baseLiquorFilter
      @_attemptScrollDown()

  _attemptScrollDown : _.debounce ->
    @refs.content.scrollTop = stylingConstants.RECIPE_LIST_ITEM_HEIGHT - stylingConstants.RECIPE_LIST_HEADER_HEIGHT / 2

  _onSearch : (searchTerm) ->
    store.dispatch {
      type : 'set-recipe-search-term'
      searchTerm
    }

}

module.exports = RecipeListView
