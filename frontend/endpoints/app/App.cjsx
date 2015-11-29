React      = require 'react'
classnames = require 'classnames'

store = require '../../store'

ReduxMixin = require '../../mixins/ReduxMixin'

RecipeListView     = require '../../recipes/RecipeListView'
SwipableRecipeView = require '../../recipes/SwipableRecipeView'
SidebarMenu        = require '../../recipes/SidebarMenu'
EditableRecipeView = require '../../recipes/EditableRecipeView'
RecipeListSelector = require '../../recipes/RecipeListSelector'

Overlay = require '../../components/Overlay'

App = React.createClass {
  displayName : 'App'

  propTypes : {}

  mixins : [
    ReduxMixin {
      recipes : 'allRecipes'
      filters : [
        'includeAllDrinks'
        'selectedRecipeList'
      ]
      ui      : [
        'recipeViewingIndex'
        'currentlyViewedRecipeIds'
        'favoritedRecipeIds'
        'showingRecipeViewer'
        'showingRecipeEditor'
        'showingSidebar'
        'showingListSelector'
      ]
    }
  ]

  render : ->
    anyOverlayVisible = _.any [
      @state.showingRecipeViewer
      @state.showingRecipeEditor
      @state.showingSidebar
      @state.showingListSelector
    ]

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
      <Overlay type='pushover' isVisible={@state.showingSidebar}>
        <SidebarMenu
          initialIncludeAllDrinks={@state.includeAllDrinks}
          onClose={@_hideSidebar}
        />
      </Overlay>
      <Overlay type='flyup' isVisible={@state.showingRecipeEditor}>
        <EditableRecipeView
          onClose={@_hideRecipeEditor}
        />
      </Overlay>
      <Overlay type='modal' isVisible={@state.showingListSelector}>
        <RecipeListSelector
          currentType={@state.selectedRecipeList}
          onClose={@_hideListSelector}
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

  _hideRecipeEditor : ->
    store.dispatch {
      type : 'hide-recipe-editor'
    }

  _hideListSelector : ->
    store.dispatch {
      type : 'hide-list-selector'
    }

  _closeOverlays : ->
    @_hideRecipeViewer()
    @_hideSidebar()
    @_hideRecipeEditor()
    @_hideListSelector()

}

module.exports = App
