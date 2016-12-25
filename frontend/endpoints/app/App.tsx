import * as React from 'react';
import * as classNames from 'classnames';

import { store } from '../../store';
import ReduxMixin from '../../mixins/ReduxMixin';

import RecipeListView from '../../recipes/RecipeListView';
import SwipableRecipeView from '../../recipes/SwipableRecipeView';
import IngredientsSidebar from '../../recipes/IngredientsSidebar';
import RecipeListSelector from '../../recipes/RecipeListSelector';
// import EditableRecipeView from '../../recipe-editor/EditableRecipeView';

import Overlay from '../../components/Overlay';

export default React.createClass({
  displayName: 'App',

  mixins: [
    ReduxMixin({
      recipes: 'allRecipes',
      filters: ['selectedRecipeList'],
      ui: ['favoritedRecipeIds', 'showingRecipeViewer', 'showingRecipeEditor', 'showingSidebar', 'showingListSelector']
    })
  ],

  render() {
    const anyOverlayVisible = [this.state.showingRecipeViewer, this.state.showingRecipeEditor, this.state.showingSidebar, this.state.showingListSelector].some(x => x);

    return (
      <div className='app-event-wrapper' onTouchStart={this._deselectActiveElement}>
        <RecipeListView />
        <div className={classNames('overlay-background', { 'visible': anyOverlayVisible })} onTouchStart={this._closeOverlays} />
        <Overlay type='modal' isVisible={this.state.showingRecipeViewer}>
          <SwipableRecipeView onClose={this._hideRecipeViewer} />
        </Overlay>
        <Overlay type='pushover' isVisible={this.state.showingSidebar}>
          <IngredientsSidebar onClose={this._hideSidebar} ref='ingredientsSidebar' />
        </Overlay>
        {/*
        <Overlay type='flyup' isVisible={this.state.showingRecipeEditor}>
          <EditableRecipeView onClose={this._hideRecipeEditor} />
        </Overlay>
        */}
        <Overlay type='modal' isVisible={this.state.showingListSelector}>
          <RecipeListSelector currentType={this.state.selectedRecipeList} onClose={this._hideListSelector} />
        </Overlay>
      </div>
    );
  },

  _deselectActiveElement() {
    if (document.activeElement) {
      (document.activeElement as any).blur();
    }
  },

  _hideRecipeViewer() {
    store.dispatch({
      type: 'hide-recipe-viewer'
    });
  },

  _hideSidebar() {
    store.dispatch({
      type: 'hide-sidebar'
    });
  },

  _hideRecipeEditor() {
    store.dispatch({
      type: 'hide-recipe-editor'
    });
  },

  _hideListSelector() {
    store.dispatch({
      type: 'hide-list-selector'
    });
  },

  _closeOverlays() {
    this.refs.ingredientsSidebar.forceClose();
    this._hideRecipeViewer();
    this._hideRecipeEditor();
    this._hideListSelector();
  }
});
