_          = require 'lodash'
React      = require 'react/addons'
classnames = require 'classnames'

{ PureRenderMixin } = React.addons

FluxMixin = require '../mixins/FluxMixin'

SearchBar          = require '../components/SearchBar'
TitleBar           = require '../components/TitleBar'
FixedHeaderFooter  = require '../components/FixedHeaderFooter'
List               = require '../components/List'
Swipable           = require '../components/Swipable'

AppDispatcher    = require '../AppDispatcher'
utils            = require '../utils'
stylingConstants = require '../stylingConstants'

{ RecipeStore, UiStore, IngredientStore } = require '../stores'

FavoritesList = require '../favorites/FavoritesList'

SwipableRecipeView = require './SwipableRecipeView'
EditableRecipeView = require './EditableRecipeView'

MIXABILITY_FILTER_NAMES = {
  mixable          : 'Mixable'
  nearMixable      : 'Nearly'
  notReallyMixable : '3+ Missing'
}

RecipeListHeader = React.createClass {
  displayName : 'RecipeListHeader'

  mixins : [
    FluxMixin UiStore, 'mixabilityFilters', 'baseLiquorFilter'
    FluxMixin IngredientStore, 'baseLiquors'
    PureRenderMixin
  ]

  render : ->
    initialBaseLiquorIndex = _.indexOf @state.baseLiquors, @state.baseLiquorFilter
    if initialBaseLiquorIndex == -1
      initialBaseLiquorIndex = 0

    <div>
      <TitleBar
        leftIcon='fa-star'
        leftIconOnTouchTap={@_openFavoritesList}
        rightIcon='fa-plus'
        rightIconOnTouchTap={@_newRecipe}
        className='recipe-list-header'
      >
        <form>
          {for key, setting of @state.mixabilityFilters
            <label className={classnames { 'selected' : setting }} key={key}>
              <input type='checkbox' value={key} checked={setting} onChange={@_onMixabilityFilterChange}/>
              <span>{MIXABILITY_FILTER_NAMES[key]}</span>
            </label>}
        </form>
      </TitleBar>
      <Swipable
        className='base-liquor-container'
        initialIndex={initialBaseLiquorIndex}
        onSlideChange={@_onBaseLiquorChange}
      >
        {for base in @state.baseLiquors
          <div
            className={classnames 'base-liquor-option', { 'selected' : base == @state.baseLiquorFilter }}
            key={base}
          >
            {base}
          </div>}
      </Swipable>
    </div>

  _onMixabilityFilterChange : (e) ->
    AppDispatcher.dispatch {
      type   : 'toggle-mixability-filter'
      filter : e.target.value
    }

  _onBaseLiquorChange : (index) ->
    AppDispatcher.dispatch {
      type   : 'set-base-liquor-filter'
      filter : @state.baseLiquors[index]
    }

  _newRecipe : ->
    AppDispatcher.dispatch {
      type      : 'show-modal'
      component : <EditableRecipeView/>
    }

  _openFavoritesList : ->
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
    onDelete   : React.PropTypes.func

  mixins : [ PureRenderMixin ]

  render : ->
    if @props.mixability == 0
      mixabilityNode = <span className='mixability mixable'>
        <i className='fa fa-check'/>
      </span>
    else if @props.mixability > 0
      mixabilityNode = <span className='mixability near-mixable'>{@props.mixability}</span>

    ListItemClass = if @props.onDelete? then List.DeletableItem else List.Item

    <ListItemClass className='recipe-list-item' onTouchTap={@props.onTouchTap} onDelete={@props.onDelete}>
      <span className='name'>{@props.recipe.name}</span>
      {mixabilityNode}
    </ListItemClass>
}

IncompleteRecipeListItem = React.createClass {
  displayName : 'IncompleteRecipeListItem'

  propTypes :
    recipe     : React.PropTypes.object.isRequired
    onTouchTap : React.PropTypes.func.isRequired
    onDelete   : React.PropTypes.func

  mixins : [ PureRenderMixin ]

  render : ->
    missingIngredients = _.map @props.recipe.missing, (m) ->
      <div className='missing-ingredient' key={m.displayIngredient}>
        <span className='amount'>{utils.fractionify(m.displayAmount ? '')}</span>
        {' '}
        <span className='unit'>{m.displayUnit ? ''}</span>
        {' '}
        <span className='ingredient'>{m.displayIngredient}</span>
      </div>

    ListItemClass = if @props.onDelete? then List.DeletableItem else List.Item

    <ListItemClass className='recipe-list-item incomplete' onTouchTap={@props.onTouchTap} onDelete={@props.onDelete}>
      <div className='name'>{@props.recipe.name}</div>
      {missingIngredients}
    </ListItemClass>
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

RecipeList = React.createClass {
  displayName : 'RecipeList'

  propTypes :
    recipes    : React.PropTypes.array.isRequired
    makeHeader : React.PropTypes.func.isRequired
    makeItem   : React.PropTypes.func.isRequired

  mixins : [ PureRenderMixin ]

  render : ->
    headeredNodes = []
    absoluteIndex = 0
    for { key, recipes } in @props.recipes
      headeredNodes.push @props.makeHeader(key, recipes)
      for r in recipes
        headeredNodes.push @props.makeItem(key, r, {
          recipe     : r
          onTouchTap : _generateRecipeOpener @props.recipes, absoluteIndex
          onDelete   : if r.isCustom then _.partial(@_deleteRecipe, r.recipeId)
          key        : r.recipeId
        })
        absoluteIndex += 1

    <List className={List.ClassNames.HEADERED}>
      {headeredNodes}
    </List>

  _deleteRecipe : (recipeId) ->
    AppDispatcher.dispatch {
      type : 'delete-recipe'
      recipeId
    }
}

RecipeListView = React.createClass {
  displayName : 'RecipeListView'

  propTypes : {}

  mixins : [
    FluxMixin(RecipeStore,
      'filteredAlphabeticalRecipes'
      'mixabilityByRecipeId'
    )
    PureRenderMixin
  ]

  render : ->
    list = <RecipeList
      recipes={@state.filteredAlphabeticalRecipes}
      makeHeader={@_alphabeticalHeader}
      makeItem={@_alphabeticalListItem}
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

  componentDidUpdate : (prevProps, prevState) ->
    if not @refs.search.isFocused() and prevState.recipeSort != @state.recipeSort
      @refs.container.scrollTo stylingConstants.RECIPE_LIST_ITEM_HEIGHT

  _onSearch : (searchTerm) ->
    AppDispatcher.dispatch {
      type : 'search-recipes'
      searchTerm
    }

  _alphabeticalHeader : (key) ->
    return <List.Header title={key.toUpperCase()} key={'header-' + key}/>

  _alphabeticalListItem : (key, r, props) ->
    return <RecipeListItem mixability={@state.mixabilityByRecipeId[r.recipeId]} {...props}/>
}

module.exports = RecipeListView
