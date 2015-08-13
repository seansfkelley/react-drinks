_          = require 'lodash'
React      = require 'react/addons'
classnames = require 'classnames'
Isvg       = require 'react-inlinesvg'

{ PureRenderMixin } = React.addons

FluxMixin = require './mixins/FluxMixin'

AppDispatcher       = require './AppDispatcher'
{ IngredientStore } = require './stores'
stylingConstants    = require './stylingConstants'

SearchBar             = require './components/SearchBar'
GroupedIngredientList = require './ingredients/GroupedIngredientList'

SidebarMenu = React.createClass {
  displayName : 'SidebarMenu'

  propTypes :
    initialIndex : React.PropTypes.number.isRequired
    onClose      : React.PropTypes.func.isRequired

  mixins : [
    FluxMixin IngredientStore, 'searchedGroupedIngredients', 'selectedIngredientTags'
    PureRenderMixin
  ]

  getDefaultProps : -> {
    initialIndex : 0
  }

  getInitialState : -> {
    index              : @props.initialIndex
    showingIngredients : false
  }

  render : ->
    <div className='sidebar-menu'>
      <div className='return-button' onTouchTap={@_closeMenu}>
        <span className='text'>Return</span>
        <i className='fa fa-chevron-right'/>
      </div>
      <div
        className={classnames 'ingredients-button', { 'showing-list' : @state.showingIngredients }}
        onTouchTap={@_toggleIngredients}
      >
        <Isvg src='/assets/img/ingredients.svg'/>
        <span className='text'>Manage Ingredients</span>
      </div>
      <div
        className={classnames 'expanding-ingredients-wrapper', { 'visible' : @state.showingIngredients }}
        ref='ingredientsContainer'
      >
        <SearchBar placeholder='Ingredient name...' onChange={@_onSearch}/>
        <GroupedIngredientList
          groupedIngredients={@state.searchedGroupedIngredients}
          initialSelectedIngredientTags={@state.selectedIngredientTags}
          ref='ingredientList'
        />
      </div>
      <div className='mixability-title'>Include</div>
      <div className='mixability-options-container'>
        <div className='input-wrapper'>
          <input type='range' min='0' max='2' value={@state.index} onChange={@_onSliderChange}/>
        </div>
        <div className='mixability-options'>
          <div className={classnames 'option', { 'is-selected' : @state.index >= 0 }} onTouchTap={@_generateLabelTapper 0}>
              Drinks I Can Make
          </div>
          <div className={classnames 'option', { 'is-selected' : @state.index >= 1 }} onTouchTap={@_generateLabelTapper 1}>
              Drinks Missing 1 Ingredient
          </div>
          <div className={classnames 'option', { 'is-selected' : @state.index >= 2 }} onTouchTap={@_generateLabelTapper 2}>
              All Drinks
          </div>
        </div>
      </div>
    </div>

  componentDidMount : ->
    @refs.ingredientsContainer.getDOMNode().scrollTop = stylingConstants.INGREDIENTS_LIST_ITEM_HEIGHT

  _toggleIngredients : ->
    @setState { showingIngredients : not @state.showingIngredients }

  _onSearch : (searchTerm) ->
    AppDispatcher.dispatch {
      type : 'search-ingredients'
      searchTerm
    }

  _onSliderChange : (e) ->
    @setState { index : _.parseInt(e.target.value) }

  _generateLabelTapper : (index) ->
    return =>
      @setState { index }

  _closeMenu : ->
    AppDispatcher.dispatch {
      type : 'set-mixability-filters'
      filters :
        mixable          : @state.index >= 0
        nearMixable      : @state.index >= 1
        notReallyMixable : @state.index >= 2
    }
    AppDispatcher.dispatch {
      type : 'set-selected-ingredient-tags'
      selectedIngredientTags : @refs.ingredientList.getSelectedTags()
    }
    @props.onClose()
}

module.exports = SidebarMenu
