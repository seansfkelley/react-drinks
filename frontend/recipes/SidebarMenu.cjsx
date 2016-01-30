_               = require 'lodash'
React           = require 'react'
classnames      = require 'classnames'
Isvg            = require 'react-inlinesvg'
PureRenderMixin = require 'react-addons-pure-render-mixin'

ReduxMixin        = require '../mixins/ReduxMixin'
DerivedValueMixin = require '../mixins/DerivedValueMixin'

store            = require '../store'
stylingConstants = require '../stylingConstants'

SearchBar             = require '../components/SearchBar'
GroupedIngredientList = require '../ingredients/GroupedIngredientList'

SidebarMenu = React.createClass {
  displayName : 'SidebarMenu'

  propTypes :
    onClose : React.PropTypes.func.isRequired

  mixins : [
    ReduxMixin {
      filters : 'selectedIngredientTags'
    }
    DerivedValueMixin 'filteredGroupedIngredients'
    PureRenderMixin
  ]

  getInitialState : -> {
    showingIngredients      : false
    # This is a little sketch, since we shouldn't have to talk to the store directly
    # because we have the mixin. But we can't peek into @state to set @state.
    selectedIngredientCount : _.size store.getState().filters.selectedIngredientTags
  }

  render : ->
    <div className='sidebar-menu'>
      <div className='return-button' onTouchTap={@_closeMenu}>
        <i className='fa fa-chevron-left'/>
        <span className='text'>Hide</span>
      </div>
      <div
        className={classnames 'ingredients-button', { 'showing-list' : @state.showingIngredients }}
        onTouchTap={@_toggleIngredients}
      >
        <Isvg src='/assets/img/ingredients.svg'/>
        <span className='text'>Manage Ingredients</span>
        {if @state.selectedIngredientCount > 0
          <span className='count'>{@state.selectedIngredientCount}</span>}
      </div>
      <div
        className={classnames 'expanding-ingredients-wrapper', { 'visible' : @state.showingIngredients }}
        ref='ingredientsContainer'
      >
        <SearchBar placeholder='Ingredient name...' onChange={@_onSearch}/>
        <GroupedIngredientList
          groupedIngredients={@state.filteredGroupedIngredients}
          initialSelectedIngredientTags={@state.selectedIngredientTags}
          onSelectionChange={@_onIngredientToggle}
          ref='ingredientList'
        />
      </div>
    </div>

  componentDidMount : ->
    @refs.ingredientsContainer.scrollTop = stylingConstants.INGREDIENTS_LIST_ITEM_HEIGHT

  _onIngredientToggle : (selectedTags) ->
    @setState { selectedIngredientCount : _.size selectedTags }

  _toggleIngredients : ->
    @setState { showingIngredients : not @state.showingIngredients }

  _onSearch : (searchTerm) ->
    store.dispatch {
      type : 'set-ingredient-search-term'
      searchTerm
    }

  _generateLabelTapper : (index) ->
    return =>
      @setState { index }

  _closeMenu : ->
    store.dispatch {
      type : 'set-selected-ingredient-tags'
      tags : @refs.ingredientList.getSelectedTags()
    }
    @props.onClose()
}

module.exports = SidebarMenu
