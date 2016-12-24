React      = require 'react'
classnames = require 'classnames'

store = require '../../store'

ReduxMixin = require '../../mixins/ReduxMixin'

RecipeListView     = require '../../recipes/RecipeListView'
SwipableRecipeView = require '../../recipes/SwipableRecipeView'
IngredientsSidebar = require '../../recipes/IngredientsSidebar'
RecipeListSelector = require '../../recipes/RecipeListSelector'
EditableRecipeView = require '../../recipe-editor/EditableRecipeView'

Overlay = require '../../components/Overlay'

App = React.createClass {
  displayName : 'App'

  propTypes : {}

  mixins : [
    ReduxMixin {
      recipes : 'allRecipes'
      filters : [
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
  ]

  render : ->
    anyOverlayVisible = _.any [
      @state.showingRecipeViewer
      @state.showingRecipeEditor
      @state.showingSidebar
      @state.showingListSelector
    ]

    React.createElement("div", {"className": 'app-event-wrapper', "onTouchStart": (@_deselectActiveElement)},
      React.createElement(RecipeListView, null),
      React.createElement("div", {"className": (classnames 'overlay-background', { 'visible' : anyOverlayVisible}), "onTouchStart": (@_closeOverlays)}),
      React.createElement(Overlay, {"type": 'modal', "isVisible": (@state.showingRecipeViewer)},
        React.createElement(SwipableRecipeView, { \
          "onClose": (@_hideRecipeViewer)
        })
      ),
      React.createElement(Overlay, {"type": 'pushover', "isVisible": (@state.showingSidebar)},
        React.createElement(IngredientsSidebar, { \
          "onClose": (@_hideSidebar),  \
          "ref": 'ingredientsSidebar'
        })
      ),
      React.createElement(Overlay, {"type": 'flyup', "isVisible": (@state.showingRecipeEditor)},
        React.createElement(EditableRecipeView, { \
          "onClose": (@_hideRecipeEditor)
        })
      ),
      React.createElement(Overlay, {"type": 'modal', "isVisible": (@state.showingListSelector)},
        React.createElement(RecipeListSelector, { \
          "currentType": (@state.selectedRecipeList),  \
          "onClose": (@_hideListSelector)
        })
      )
    )

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
    @refs.ingredientsSidebar.forceClose()
    @_hideRecipeViewer()
    @_hideRecipeEditor()
    @_hideListSelector()

}

module.exports = App