_          = require 'lodash'
React      = require 'react/addons'
classnames = require 'classnames'
Isvg       = require 'react-inlinesvg'

{ PureRenderMixin } = React.addons

ReduxMixin        = require '../mixins/ReduxMixin'
DerivedValueMixin = require '../mixins/DerivedValueMixin'

store            = require '../store'
stylingConstants = require '../stylingConstants'

SearchBar             = require '../components/SearchBar'
GroupedIngredientList = require '../ingredients/GroupedIngredientList'

SidebarMenu = React.createClass {
  displayName : 'SidebarMenu'

  propTypes :
    initialIncludeAllDrinks : React.PropTypes.bool.isRequired
    onClose                 : React.PropTypes.func.isRequired

  mixins : [
    ReduxMixin {
      filters : 'selectedIngredientTags'
    }
    DerivedValueMixin 'filteredGroupedIngredients'
    PureRenderMixin
  ]

  getInitialState : -> {
    includeAllDrinks        : @props.initialIncludeAllDrinks
    showingIngredients      : false
    # This is a little sketch, since we shouldn't have to talk to the store directly
    # because we have the mixin. But we can't peek into @state to set @state.
    selectedIngredientCount : _.size store.getState().filters.selectedIngredientTags
  }

  render : ->
    <div className='sidebar-menu'>
      <div className='return-button' onTouchTap={@_closeMenu}>
        <span className='text'>Drinks</span>
        <i className='fa fa-chevron-right'/>
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
      <div className='mixability-title'>Include</div>
      <div className='mixability-options-container'>
      </div>
    </div>
    # Replace this with a pretty checkbox.
        # <div className='input-wrapper'>
        #   <input type='range' min='0' max='2' value={@state.index} onChange={@_onSliderChange}/>
        # </div>
        # <div className='mixability-options'>
        #   {@_createOption 'Drinks I Can Make', 0}
        #   {@_createOption 'Drinks Missing 1 Ingredient', 1}
        #   {@_createOption 'All Drinks', 2}
        # </div>

  # _createOption : (text, value) ->
  #   return <div
  #     className={classnames 'option', { 'is-selected' : @state.index >= value }}
  #     onTouchTap={@_generateLabelTapper value}
  #   >
  #       {text}
  #   </div>

  componentDidMount : ->
    @refs.ingredientsContainer.getDOMNode().scrollTop = stylingConstants.INGREDIENTS_LIST_ITEM_HEIGHT

  _onIngredientToggle : (selectedTags) ->
    @setState { selectedIngredientCount : _.size selectedTags }

  _toggleIngredients : ->
    @setState { showingIngredients : not @state.showingIngredients }

  _onSearch : (searchTerm) ->
    store.dispatch {
      type : 'set-ingredient-search-term'
      searchTerm
    }

  _onSliderChange : (e) ->
    @setState { index : _.parseInt(e.target.value) }

  _generateLabelTapper : (index) ->
    return =>
      @setState { index }

  _closeMenu : ->
    store.dispatch {
      type    : 'set-include-all-drinks'
      include : @state.includeAllDrinks
    }
    store.dispatch {
      type : 'set-selected-ingredient-tags'
      tags : @refs.ingredientList.getSelectedTags()
    }
    @props.onClose()
}

module.exports = SidebarMenu
