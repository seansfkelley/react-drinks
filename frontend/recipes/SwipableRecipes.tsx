
import * as React from 'react';
import { Dispatch, bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import Swipable from '../components/Swipable';

import { Recipe } from '../../shared/types';
import { RootState } from '../store';
import {
  setRecipeViewingIndex,
  hideRecipeViewer,
  showRecipeViewer
} from '../store/atomicActions';
import InteractiveRecipe from './InteractiveRecipe';

interface ConnectedProps {
  recipesById: { [recipeId: string]: Recipe };
  currentlyViewedRecipeIds: string[];
  recipeViewingIndex: number;
}

interface DispatchProps {
  setRecipeViewingIndex: typeof setRecipeViewingIndex;
  hideRecipeViewer: typeof hideRecipeViewer;
  showRecipeViewer: typeof showRecipeViewer;
}

class SwipableRecipes extends React.PureComponent<ConnectedProps & DispatchProps, void> {
  private _swipable: Swipable;

  render() {
    if (this.props.currentlyViewedRecipeIds.length === 0) {
      return <div />;
    } else {
      const recipePages = this.props.currentlyViewedRecipeIds.map((recipeId, i) => {
        return (
          <div className='swipable-padding-wrapper' key={recipeId}>
            {Math.abs(i - this.props.recipeViewingIndex) <= 1
              ? this._renderRecipe(this.props.recipesById[recipeId])
              : undefined}
          </div>
        );
      });

      return (
        <Swipable
          className='swipable-recipes-container'
          initialIndex={this.props.recipeViewingIndex}
          onIndexChange={this.props.setRecipeViewingIndex}
          friction={0.9}
          ref={e => this._swipable = e}
        >
          {recipePages}
        </Swipable>
      );
    }
  }

  _renderRecipe(recipe: Recipe) {
    return (
      <div className='swipable-position-wrapper'>
        <InteractiveRecipe
          recipe={recipe}
          showFavoriteButton={true}
          showShareButton={true}
          showSimilarRecipes={true}
          onSimilarRecipeClick={this._replaceWithRecipeId}
          onClose={this._onClose}
        />
      </div>
    );
  }

  componentWillReceiveProps(nextProps: ConnectedProps) {
    if (this._swipable && nextProps.recipeViewingIndex !== this.props.recipeViewingIndex) {
      this._swipable.setIndexToIfNecessary(nextProps.recipeViewingIndex);
    }
  }

  private _replaceWithRecipeId = (recipeId: string) => {
    this.props.showRecipeViewer({ recipeIds: [ recipeId ], index: 0 });
  };

  private _onClose = () => {
    this.props.setRecipeViewingIndex(0);
    this.props.hideRecipeViewer();
  };
}

function mapDispatchToProps(dispatch: Dispatch<RootState>): DispatchProps {
  return bindActionCreators({
    setRecipeViewingIndex,
    hideRecipeViewer,
    showRecipeViewer
  }, dispatch);
}

function mapStateToProps(state: RootState): ConnectedProps {
  return {
    recipesById: state.recipes.recipesById,
    currentlyViewedRecipeIds: state.ui.currentlyViewedRecipeIds,
    recipeViewingIndex: state.ui.recipeViewingIndex
  };
}

export default connect(mapStateToProps, mapDispatchToProps)(SwipableRecipes) as React.ComponentClass<void>;
