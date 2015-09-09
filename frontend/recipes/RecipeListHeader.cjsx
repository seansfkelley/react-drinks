_          = require 'lodash'
React      = require 'react/addons'
classnames = require 'classnames'

{ PureRenderMixin } = React.addons

definitions = require '../../shared/definitions'

ReduxMixin = require '../mixins/ReduxMixin'

TitleBar = require '../components/TitleBar'
Swipable = require '../components/Swipable'

store         = require '../store'
overlayViews  = require '../overlayViews'

EditableRecipeView      = require './EditableRecipeView'
SidebarMenu             = require './SidebarMenu'
IngredientSelectionView = require '../ingredients/IngredientSelectionView'

BASE_LIQUORS = [ definitions.ANY_BASE_LIQUOR ].concat definitions.BASE_LIQUORS

RecipeListHeader = React.createClass {
  displayName : 'RecipeListHeader'

  mixins : [
    ReduxMixin {
      filters : [ 'mixabilityFilters', 'baseLiquorFilter' ]
    }
    PureRenderMixin
  ]

  render : ->
    initialBaseLiquorIndex = _.indexOf BASE_LIQUORS, @state.baseLiquorFilter
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
        {for base in BASE_LIQUORS
          <div
            className={classnames 'base-liquor-option', { 'selected' : base == @state.baseLiquorFilter }}
            key={base}
          >
            {base}
          </div>}
      </Swipable>
    </div>

  _onBaseLiquorChange : (index) ->
    store.dispatch {
      type   : 'set-base-liquor-filter'
      filter : BASE_LIQUORS[index]
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
