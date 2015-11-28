React      = require 'react'
classnames = require 'classnames'

store = require '../../store'

ReduxMixin = require '../../mixins/ReduxMixin'

RecipeListView     = require '../../recipes/RecipeListView'
SwipableRecipeView = require '../../recipes/SwipableRecipeView'
SidebarMenu        = require '../../recipes/SidebarMenu'

Overlay = require '../../components/Overlay'

App = React.createClass {
  displayName : 'App'

  propTypes : {}

  mixins : [
    ReduxMixin {
      recipes : 'allRecipes'
      filters : 'includeAllDrinks'
      ui      : [
        'recipeViewingIndex'
        'currentlyViewedRecipeIds'
        'favoritedRecipeIds'
        'showingRecipeViewer'
        'showingRecipeEditor'
        'showingSidebar'
      ]
    }
  ]

  render : ->
    anyOverlayVisible = _.any [ @state.showingRecipeViewer, @state.showingRecipeEditor, @state.showingSidebar ]

    <div className='app-event-wrapper' onTouchStart={@_deselectActiveElement}>
      <RecipeListView/>
      <div className={classnames 'overlay-background', { 'visible' : anyOverlayVisible}} onTouchStart={@_closeOverlays}/>
      <Overlay type='modal' isVisible={@state.showingRecipeViewer}>
        <SwipableRecipeView
          recipeIds={@state.currentlyViewedRecipeIds}
          index={@state.recipeViewingIndex}
          onClose={@_hideRecipeViewer}
        />
      </Overlay>
      <Overlay type='pushover'isVisible={@state.showingSidebar}>
        <SidebarMenu
          initialIncludeAllDrinks={@state.includeAllDrinks}
          onClose={@_hideSidebar}
        />
      </Overlay>
    </div>

  _deselectActiveElement : ->
    document.activeElement?.blur()

  _hideRecipeViewer : ->
    store.dispatch {
      type : 'hide-recipe-viewer'
    }

  _hideSidebar : ->
    store.dispatch {
      type : 'hide-sidebar'
    }

  _closeOverlays : ->
    @_hideRecipeViewer()
    @_hideSidebar()

}

module.exports = App
