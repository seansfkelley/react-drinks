const React      = require('react');
const classnames = require('classnames');

const store = require('../../store');

const ReduxMixin = require('../../mixins/ReduxMixin');

const RecipeListView     = require('../../recipes/RecipeListView');
const SwipableRecipeView = require('../../recipes/SwipableRecipeView');
const IngredientsSidebar = require('../../recipes/IngredientsSidebar');
const RecipeListSelector = require('../../recipes/RecipeListSelector');
const EditableRecipeView = require('../../recipe-editor/EditableRecipeView');

const Overlay = require('../../components/Overlay');

const App = React.createClass({
  displayName : 'App',

  propTypes : {},

  mixins : [
    ReduxMixin({
      recipes : 'allRecipes',
      filters : [
        'selectedRecipeList'
      ],
      ui      : [
        'favoritedRecipeIds',
        'showingRecipeViewer',
        'showingRecipeEditor',
        'showingSidebar',
        'showingListSelector'
      ]
    })
  ],

  render() {
    const anyOverlayVisible = _.any([
      this.state.showingRecipeViewer,
      this.state.showingRecipeEditor,
      this.state.showingSidebar,
      this.state.showingListSelector
    ]);

    return React.createElement("div", {"className": 'app-event-wrapper', "onTouchStart": (this._deselectActiveElement)},
      React.createElement(RecipeListView, null),
      React.createElement("div", {"className": (classnames('overlay-background', { 'visible' : anyOverlayVisible})), "onTouchStart": (this._closeOverlays)}),
      React.createElement(Overlay, {"type": 'modal', "isVisible": (this.state.showingRecipeViewer)},
        React.createElement(SwipableRecipeView, { 
          "onClose": (this._hideRecipeViewer)
        })
      ),
      React.createElement(Overlay, {"type": 'pushover', "isVisible": (this.state.showingSidebar)},
        React.createElement(IngredientsSidebar, { 
          "onClose": (this._hideSidebar),  
          "ref": 'ingredientsSidebar'
        })
      ),
      React.createElement(Overlay, {"type": 'flyup', "isVisible": (this.state.showingRecipeEditor)},
        React.createElement(EditableRecipeView, { 
          "onClose": (this._hideRecipeEditor)
        })
      ),
      React.createElement(Overlay, {"type": 'modal', "isVisible": (this.state.showingListSelector)},
        React.createElement(RecipeListSelector, { 
          "currentType": (this.state.selectedRecipeList),  
          "onClose": (this._hideListSelector)
        })
      )
    );
  },

  _deselectActiveElement() {
    return __guard__(document.activeElement, x => x.blur());
  },

  _hideRecipeViewer() {
    return store.dispatch({
      type : 'hide-recipe-viewer'
    });
  },

  _hideSidebar() {
    return store.dispatch({
      type : 'hide-sidebar'
    });
  },

  _hideRecipeEditor() {
    return store.dispatch({
      type : 'hide-recipe-editor'
    });
  },

  _hideListSelector() {
    return store.dispatch({
      type : 'hide-list-selector'
    });
  },

  _closeOverlays() {
    this.refs.ingredientsSidebar.forceClose();
    this._hideRecipeViewer();
    this._hideRecipeEditor();
    return this._hideListSelector();
  }

});

module.exports = App;

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}