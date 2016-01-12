React           = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'
classnames      = require 'classnames'

store = require '../../store'

ReduxMixin = require '../../mixins/ReduxMixin'

RecipeListView     = require '../../recipes/RecipeListView'
SwipableRecipeView = require '../../recipes/SwipableRecipeView'
SidebarMenu        = require '../../recipes/SidebarMenu'
RecipeListSelector = require '../../recipes/RecipeListSelector'
RecipeEditorView   = require '../../recipe-editor/RecipeEditorView'

Overlay = require '../../components/Overlay'

stylingConstants = require '../../stylingConstants'

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
        'favoritedRecipeIds'
        'showingRecipeViewer'
        'showingRecipeEditor'
        'showingSidebar'
        'showingListSelector'
      ]
    }
    PureRenderMixin
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
        <RecipeEditorView
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
    # Definitely a hack, but we don't want to rerender the default page until it's not visible.
    _.delay (->
      store.dispatch {
        type : 'clear-editable-recipe'
      }
    ), stylingConstants.TRANSITION_DURATION

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
