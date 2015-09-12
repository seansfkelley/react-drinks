_          = require 'lodash'
React      = require 'react/addons'

{ PureRenderMixin } = React.addons

ReduxMixin        = require '../mixins/ReduxMixin'
DerivedValueMixin = require '../mixins/DerivedValueMixin'

SearchBar          = require '../components/SearchBar'
FixedHeaderFooter  = require '../components/FixedHeaderFooter'
List               = require '../components/List'

store            = require '../store'
utils            = require '../utils'
stylingConstants = require '../stylingConstants'
overlayViews     = require '../overlayViews'

SwipableRecipeView = require './SwipableRecipeView'
RecipeListItem     = require './RecipeListItem'
RecipeListHeader   = require './RecipeListHeader'

RecipeList = React.createClass {
  displayName : 'RecipeList'

  propTypes :
    recipes                    : React.PropTypes.array.isRequired
    makeHeader                 : React.PropTypes.func.isRequired
    makeItem                   : React.PropTypes.func.isRequired
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
        listNodes.push @props.makeHeader(key, recipes)
      for r in recipes
        listNodes.push @props.makeItem(key, r, {
          # TODO: This can acuse needless rerenders, especially when text-searching.
          # PureRenderMixin is bypassed since .bind() returns a new function every time.
          # Is there a way to always pass the same function and infer the index from the event?
          onTouchTap : SwipableRecipeView.showInModal.bind(null, @props.recipes, @props.ingredientSplitsByRecipeId, absoluteIndex)
          onDelete   : if r.isCustom then _.partial(@_deleteRecipe, r.recipeId)
          key        : r.recipeId
        })
        absoluteIndex += 1

    <List className={List.ClassNames.HEADERED}>
      {listNodes}
    </List>

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
      filters : [ 'recipeSearchTerm', 'baseLiquorFilter' ]
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
      makeHeader={@_alphabeticalHeader}
      makeItem={@_alphabeticalListItem}
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

  _alphabeticalHeader : (key) ->
    return <List.Header title={key.toUpperCase()} key={'header-' + key}/>

  _alphabeticalListItem : (key, r, props) ->
    return <RecipeListItem mixability={@state.ingredientSplitsByRecipeId[r.recipeId].missing.length} recipeName={r.name} {...props}/>
}

module.exports = RecipeListView
