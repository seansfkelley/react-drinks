_     = require 'lodash'
React = require 'react/addons'

{ PureRenderMixin } = React.addons

FluxMixin = require '../mixins/FluxMixin'

TitleBar          = require '../components/TitleBar'
FixedHeaderFooter = require '../components/FixedHeaderFooter'
SearchBar         = require '../components/SearchBar'

AppDispatcher       = require '../AppDispatcher'
stylingConstants    = require '../stylingConstants'
overlayViews        = require '../overlayViews'
{ IngredientStore } = require '../stores'

GroupedIngredientList = require './GroupedIngredientList'

IngredientSelectionHeader = React.createClass {
  displayName : 'IngredientSelectionHeader'

  propTypes :
    onClose : React.PropTypes.func

  mixins : [ PureRenderMixin ]

  render : ->
    <TitleBar leftIcon='fa-chevron-down' leftIconOnTouchTap={@props.onClose}>
      Ingredients
    </TitleBar>
}

IngredientSelectionView = React.createClass {
  displayName : 'IngredientSelectionView'

  propTypes : {}

  mixins : [
    FluxMixin IngredientStore, 'searchedGroupedIngredients', 'selectedIngredientTags'
    PureRenderMixin
  ]

  render : ->
    <FixedHeaderFooter
      className='ingredient-selection-view'
      header={<IngredientSelectionHeader onClose={@_onClose}/>}
      ref='container'
    >
      <SearchBar placeholder='Ingredient name...' onChange={@_onSearch}/>
      <GroupedIngredientList
        groupedIngredients={@state.searchedGroupedIngredients}
        initialSelectedIngredientTags={@state.selectedIngredientTags}
        ref='ingredientList'
      />
    </FixedHeaderFooter>

  componentDidMount : ->
    @refs.container.scrollTo stylingConstants.INGREDIENTS_LIST_ITEM_HEIGHT

  # In the future, this should pop up a loader and then throttle the number of filters performed.
  _onSearch : (searchTerm) ->
    AppDispatcher.dispatch {
      type : 'search-ingredients'
      searchTerm
    }

  _onClose : ->
    overlayViews.flyup.hide()
    AppDispatcher.dispatch {
      type       : 'search-ingredients'
      searchTerm : ''
    }
    AppDispatcher.dispatch {
      type : 'set-selected-ingredient-tags'
      selectedIngredientTags : @refs.ingredientList.getSelectedTags()
    }
}


module.exports = IngredientSelectionView
