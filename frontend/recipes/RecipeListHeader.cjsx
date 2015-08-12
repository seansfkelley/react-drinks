_          = require 'lodash'
React      = require 'react/addons'
classnames = require 'classnames'

{ PureRenderMixin } = React.addons

FluxMixin = require '../mixins/FluxMixin'

TitleBar = require '../components/TitleBar'
Swipable = require '../components/Swipable'

AppDispatcher = require '../AppDispatcher'
overlayViews  = require '../overlayViews'

{ UiStore, IngredientStore } = require '../stores'

EditableRecipeView      = require './EditableRecipeView'
MixabilityToggle        = require './MixabilityToggle'
IngredientSelectionView = require '../ingredients/IngredientSelectionView'
SidebarMenu             = require '../SidebarMenu'

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

        # leftIcon='/assets/img/ingredients.svg'
        # leftIconOnTouchTap={@_openIngredientPanel}
    <div>
      <TitleBar
        leftIcon='fa-bars'
        leftIconOnTouchTap={@_showSidebar}
        rightIcon='fa-plus'
        rightIconOnTouchTap={@_newRecipe}
        className='recipe-list-header'
      >
        <MixabilityToggle
          mixabilityToggles={@state.mixabilityFilters}
          onToggle={@_onMixabilityFilterChange}
        />
      </TitleBar>
      <Swipable
        className='base-liquor-container'
        initialIndex={initialBaseLiquorIndex}
        onSlideChange={@_onBaseLiquorChange}
        friction=0.7
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

  _onMixabilityFilterChange : (filter) ->
    AppDispatcher.dispatch {
      type   : 'toggle-mixability-filter'
      filter
    }

  _onBaseLiquorChange : (index) ->
    if @state.baseLiquors[index] == UiStore.baseLiquorFilter
      return

    AppDispatcher.dispatch {
      type   : 'set-base-liquor-filter'
      filter : @state.baseLiquors[index]
    }

  _showSidebar : ->
    overlayViews.pushover.show <SidebarMenu/>

  _newRecipe : ->
    overlayViews.flyup.show <EditableRecipeView/>

  _openIngredientPanel : ->
    overlayViews.flyup.show <IngredientSelectionView/>
}

module.exports = RecipeListHeader
