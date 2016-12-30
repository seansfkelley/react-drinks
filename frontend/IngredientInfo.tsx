import * as React from 'react';
import { Dispatch, bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import { RootState } from './store';
import { hideIngredientInfo } from './store/atomicActions';
import { Ingredient } from '../shared/types';
import TitleBar from './components/TitleBar';

interface ConnectedProps {
  ingredientTag?: string;
  ingredientsByTag: { [tag: string]: Ingredient };
}

interface DispatchProps {
  hideIngredientInfo: typeof hideIngredientInfo;
}

class IngredientInfo extends React.PureComponent<ConnectedProps & DispatchProps, void> {
  render() {
    if (this.props.ingredientTag) {
      return (
        <div className='ingredient-info'>
          <TitleBar
            rightIcon='fa-times'
            rightIconOnClick={this.props.hideIngredientInfo}
          >
            {this.props.ingredientsByTag[this.props.ingredientTag].display}
          </TitleBar>
        </div>
      );
    } else {
      return null;
    }
  }
}

function mapStateToProps(state: RootState): ConnectedProps {
  return {
    ingredientTag: state.ui.currentIngredientInfo,
    ingredientsByTag: state.ingredients.ingredientsByTag
  };
}

function mapDispatchToProps(dispatch: Dispatch<RootState>): DispatchProps {
  return bindActionCreators({ hideIngredientInfo }, dispatch);
}

export default connect(mapStateToProps, mapDispatchToProps)(IngredientInfo) as React.ComponentClass<void>;
