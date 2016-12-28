import * as React from 'react';
import * as classNames from 'classnames';
import { connect } from 'react-redux';
import { Dispatch, bindActionCreators } from 'redux';

import { RootState } from '../../store';
import {
  hideRecipeViewer,
  hideSidebar,
  hideRecipeEditor,
  hideListSelector,
  setSelectedIngredientTags
} from '../../store/atomicActions';

import MainSearchUiThing from '../../search/MainSearchUiThing';
import SwipableRecipeView from '../../recipes/SwipableRecipeView';
import IngredientsSidebar from '../../recipes/IngredientsSidebar';
import RecipeListSelector from '../../recipes/RecipeListSelector';

import Overlay from '../../components/Overlay';

interface ConnectedProps {
  selectedRecipeList: string;
  favoritedRecipeIds: string[];
  showingRecipeViewer: boolean;
  showingRecipeEditor: boolean;
  showingSidebar: boolean;
  showingListSelector: boolean;
}

interface DispatchProps {
  hideRecipeViewer: typeof hideRecipeViewer;
  hideSidebar: typeof hideSidebar;
  hideRecipeEditor: typeof hideRecipeEditor;
  hideListSelector: typeof hideListSelector;
  setSelectedIngredientTags: typeof setSelectedIngredientTags;
}

interface State {
  pendingIngredientTags: string[];
}

class App extends React.PureComponent<ConnectedProps & DispatchProps, State> {
  state: State = {
    pendingIngredientTags: []
  };

  render() {
    const anyOverlayVisible = [
      this.props.showingRecipeViewer,
      this.props.showingRecipeEditor,
      this.props.showingSidebar,
      this.props.showingListSelector
    ].some(x => x);

    return (
      <div className='app-event-wrapper' onTouchStart={this._deselectActiveElement}>
        <MainSearchUiThing />
        <div
          className={classNames('overlay-background', { 'visible': anyOverlayVisible })}
          onTouchStart={this._closeOverlays}
        />
        <Overlay type='modal' isVisible={this.props.showingRecipeViewer}>
          <SwipableRecipeView />
        </Overlay>
        <Overlay type='pushover' isVisible={this.props.showingSidebar}>
          <IngredientsSidebar onPendingTagsChange={this._onPendingTagsChange} />
        </Overlay>
        {/*
        <Overlay type='flyup' isVisible={this.props.showingRecipeEditor}>
          <EditableRecipeView onClose={this.props.hideRecipeEditor} />
        </Overlay>
        */}
        <Overlay type='modal' isVisible={this.props.showingListSelector}>
          <RecipeListSelector />
        </Overlay>
      </div>
    );
  }

  _deselectActiveElement() {
    if (document.activeElement) {
      (document.activeElement as HTMLElement).blur();
    }
  }

  private _closeOverlays = (e: React.TouchEvent<HTMLElement>) => {
    this.props.hideSidebar();
    this.props.hideRecipeViewer();
    this.props.hideRecipeEditor();
    this.props.hideListSelector();

    this.props.setSelectedIngredientTags(this.state.pendingIngredientTags);

    // This prevent events from leaking to elements behind the backdrop.
    e.preventDefault();
  };

  private _onPendingTagsChange = (pendingIngredientTags: string[]) => {
    this.setState({ pendingIngredientTags });
  };
}

function mapStateToProps(state: RootState): ConnectedProps {
  return {
    selectedRecipeList: state.filters.selectedRecipeList,
    favoritedRecipeIds: state.ui.favoritedRecipeIds,
    showingRecipeViewer: state.ui.showingRecipeViewer,
    showingRecipeEditor: state.ui.showingRecipeEditor,
    showingSidebar: state.ui.showingSidebar,
    showingListSelector: state.ui.showingListSelector
  };
}

function mapDispatchToProps(dispatch: Dispatch<RootState>): DispatchProps {
  return bindActionCreators({
    hideRecipeViewer,
    hideSidebar,
    hideRecipeEditor,
    hideListSelector,
    setSelectedIngredientTags
  }, dispatch);
}

export default connect(mapStateToProps, mapDispatchToProps)(App) as React.ComponentClass<void>;
