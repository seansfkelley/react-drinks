_          = require 'lodash'
React      = require 'react/addons'
classnames = require 'classnames'

{ PureRenderMixin } = React.addons

ReduxMixin = require '../mixins/ReduxMixin'

TitleBar = require '../components/TitleBar'
Swipable = require '../components/Swipable'

store         = require '../store'
overlayViews  = require '../overlayViews'

EditableRecipeView      = require './EditableRecipeView'
SidebarMenu             = require './SidebarMenu'
IngredientSelectionView = require '../ingredients/IngredientSelectionView'

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
        leftIcon='fa-bars'
        leftIconOnTouchTap={@_showSidebar}
        rightIcon='fa-plus'
        rightIconOnTouchTap={@_newRecipe}
        className='recipe-list-header'
      >
        Spirit Guide
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

  _onBaseLiquorChange : (index) ->
    if @state.baseLiquors[index] == UiStore.baseLiquorFilter
      return

    store.dispatch {
      type   : 'set-base-liquor-filter'
      filter : @state.baseLiquors[index]
    }

  _showSidebar : ->
    if @state.mixabilityFilters.notReallyMixable
      initialIndex = 2
    else if @state.mixabilityFilters.nearMixable
      initialIndex = 1
    else
      initialIndex = 0

    overlayViews.pushover.show <SidebarMenu
      initialIndex={initialIndex}
      onClose={overlayViews.pushover.hide}
    />

  _newRecipe : ->
    overlayViews.flyup.show <EditableRecipeView/>

  _openIngredientPanel : ->
    overlayViews.flyup.show <IngredientSelectionView/>
}

module.exports = RecipeListHeader
