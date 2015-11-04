_               = require 'lodash'
React           = require 'react'
classnames      = require 'classnames'
PureRenderMixin = require 'react-addons-pure-render-mixin'

definitions = require '../../shared/definitions'

ReduxMixin = require '../mixins/ReduxMixin'

TitleBar = require '../components/TitleBar'
Swipable = require '../components/Swipable'

store         = require '../store'
overlayViews  = require '../overlayViews'

SidebarMenu        = require './SidebarMenu'
EditableRecipeView = require './EditableRecipeView'

BASE_LIQUORS = [ definitions.ANY_BASE_LIQUOR ].concat definitions.BASE_LIQUORS

RecipeListHeader = React.createClass {
  displayName : 'RecipeListHeader'

  mixins : [
    ReduxMixin {
      filters : [ 'includeAllDrinks', 'baseLiquorFilter' ]
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
    overlayViews.pushover.show <SidebarMenu
      initialIncludeAllDrinks={@state.includeAllDrinks}
      onClose={overlayViews.pushover.hide}
    />

  _newRecipe : ->
    overlayViews.flyup.show <EditableRecipeView/>
}

module.exports = RecipeListHeader
