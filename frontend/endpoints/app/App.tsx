import * as React from 'react';
import { connect } from 'react-redux';
import { Dispatch, bindActionCreators } from 'redux';

import { RootState } from '../../store';
import {
  hideRecipeViewer,
  hideIngredientInfo
} from '../../store/atomicActions';

import Landing from '../../Landing';
import SwipableRecipeView from '../../recipes/SwipableRecipeView';
import IngredientInfo from '../../IngredientInfo';

import Overlay from '../../components/Overlay';

interface ConnectedProps {
  showingRecipeViewer: boolean;
  showingIngredientInfo: boolean;
}

interface DispatchProps {
  hideRecipeViewer: typeof hideRecipeViewer;
  hideIngredientInfo: typeof hideIngredientInfo;
}

interface State {
  pendingIngredientTags: string[];
}

class App extends React.PureComponent<ConnectedProps & DispatchProps, State> {
  state: State = {
    pendingIngredientTags: []
  };

  render() {
    return (
      <div
        className='app-event-wrapper'
        onTouchStart={this._deselectActiveElement}
      >
        <Landing />
        <Overlay
          type='modal'
          isVisible={this.props.showingRecipeViewer}
          onBackdropClick={this.props.hideRecipeViewer}
        >
          <SwipableRecipeView />
        </Overlay>
        <Overlay
          type='modal'
          isVisible={this.props.showingIngredientInfo}
          onBackdropClick={this.props.hideIngredientInfo}
        >
          <IngredientInfo />
        </Overlay>
      </div>
    );
  }

  _deselectActiveElement() {
    if (document.activeElement) {
      (document.activeElement as HTMLElement).blur();
    }
  }
}

function mapStateToProps(state: RootState): ConnectedProps {
  return {
    showingRecipeViewer: state.ui.showingRecipeViewer,
    showingIngredientInfo: !!state.ui.currentIngredientInfo
  };
}

function mapDispatchToProps(dispatch: Dispatch<RootState>): DispatchProps {
  return bindActionCreators({
    hideRecipeViewer,
    hideIngredientInfo
  }, dispatch);
}

export default connect(mapStateToProps, mapDispatchToProps)(App) as React.ComponentClass<void>;
