import * as React from 'react';
const classnames = require('classnames');

const store = require('../../store');

const ReduxMixin = require('../../mixins/ReduxMixin');

const RecipeListView = require('../../recipes/RecipeListView');
const SwipableRecipeView = require('../../recipes/SwipableRecipeView');
const IngredientsSidebar = require('../../recipes/IngredientsSidebar');
const RecipeListSelector = require('../../recipes/RecipeListSelector');
const EditableRecipeView = require('../../recipe-editor/EditableRecipeView');

const Overlay = require('../../components/Overlay');

const App = React.createClass({
  displayName: 'App',

  propTypes: {},

  mixins: [ReduxMixin({
    recipes: 'allRecipes',
    filters: ['selectedRecipeList'],
    ui: ['favoritedRecipeIds', 'showingRecipeViewer', 'showingRecipeEditor', 'showingSidebar', 'showingListSelector']
  })],

  render() {
    const anyOverlayVisible = _.any([this.state.showingRecipeViewer, this.state.showingRecipeEditor, this.state.showingSidebar, this.state.showingListSelector]);

    return <div className='app-event-wrapper' onTouchStart={this._deselectActiveElement}><RecipeListView /><div className={classnames('overlay-background', { 'visible': anyOverlayVisible })} onTouchStart={this._closeOverlays} /><Overlay type='modal' isVisible={this.state.showingRecipeViewer}><SwipableRecipeView onClose={this._hideRecipeViewer} /></Overlay><Overlay type='pushover' isVisible={this.state.showingSidebar}><IngredientsSidebar onClose={this._hideSidebar} ref='ingredientsSidebar' /></Overlay><Overlay type='flyup' isVisible={this.state.showingRecipeEditor}><EditableRecipeView onClose={this._hideRecipeEditor} /></Overlay><Overlay type='modal' isVisible={this.state.showingListSelector}><RecipeListSelector currentType={this.state.selectedRecipeList} onClose={this._hideListSelector} /></Overlay></div>;
  },

  _deselectActiveElement() {
    return __guard__(document.activeElement, x => x.blur());
  },

  _hideRecipeViewer() {
    return store.dispatch({
      type: 'hide-recipe-viewer'
    });
  },

  _hideSidebar() {
    return store.dispatch({
      type: 'hide-sidebar'
    });
  },

  _hideRecipeEditor() {
    return store.dispatch({
      type: 'hide-recipe-editor'
    });
  },

  _hideListSelector() {
    return store.dispatch({
      type: 'hide-list-selector'
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
  return typeof value !== 'undefined' && value !== null ? transform(value) : undefined;
}
