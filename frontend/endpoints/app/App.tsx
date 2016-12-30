import * as React from 'react';
import * as classNames from 'classnames';
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
    const anyOverlayVisible = [
      this.props.showingRecipeViewer,
      this.props.showingIngredientInfo
    ].some(x => x);

    return (
      <div className='app-event-wrapper' onTouchStart={this._deselectActiveElement}>
        <Landing />
        <div
          className={classNames('overlay-background', { 'visible': anyOverlayVisible })}
          onTouchStart={this._closeOverlays}
        />
        <Overlay type='modal' isVisible={this.props.showingRecipeViewer}>
          <SwipableRecipeView />
        </Overlay>
        <Overlay type='modal' isVisible={this.props.showingIngredientInfo}>
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

  private _closeOverlays = (e: React.TouchEvent<HTMLElement>) => {
    this.props.hideRecipeViewer();
    this.props.hideIngredientInfo();

    // This prevent events from leaking to elements behind the backdrop.
    e.preventDefault();
  };
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
