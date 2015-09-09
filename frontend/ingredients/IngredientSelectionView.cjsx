_     = require 'lodash'
React = require 'react/addons'

{ PureRenderMixin } = React.addons

ReduxMixin        = require '../mixins/ReduxMixin'
DerivedValueMixin = require '../mixins/DerivedValueMixin'

TitleBar          = require '../components/TitleBar'
FixedHeaderFooter = require '../components/FixedHeaderFooter'
SearchBar         = require '../components/SearchBar'

store               = require '../store'
stylingConstants    = require '../stylingConstants'
overlayViews        = require '../overlayViews'

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
    ReduxMixin {
      filters : 'selectedIngredientTags'
    }
    DerivedValueMixin 'searchedGroupedIngredients'
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
    store.dispatch {
      type : 'set-ingredient-search-term'
      searchTerm
    }

  _onClose : ->
    overlayViews.flyup.hide()
    store.dispatch {
      type       : 'set-ingredient-search-term'
      searchTerm : ''
    }
    store.dispatch {
      type : 'set-selected-ingredient-tags'
      selectedIngredientTags : @refs.ingredientList.getSelectedTags()
    }
}


module.exports = IngredientSelectionView
