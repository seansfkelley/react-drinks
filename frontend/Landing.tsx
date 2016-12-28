import { sample } from 'lodash';
import * as React from 'react';
import { Dispatch, bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import { assert } from '../shared/tinyassert';
import { RootState } from './store';
import { selectFilteredGroupedIngredients } from './store/selectors';
import { setIngredientSearchTerm, setSelectedIngredientTags } from './store/atomicActions';
import { GroupedIngredients } from './types';
import { Recipe } from '../shared/types';
import BlurOverlay from './components/BlurOverlay';
import TitleBar from './components/TitleBar';
import SearchBar from './components/SearchBar';
import RecipeView from './recipes/RecipeView';
import GroupedIngredientList from './ingredients/GroupedIngredientList';

interface ConnectedProps {
  recipesById: { [recipeId: string]: Recipe };
  ingredientSearchTerm: string;
  selectedIngredientTags: string[];
  filteredGroupedIngredients: GroupedIngredients[];
}

interface DispatchProps {
  setIngredientSearchTerm: typeof setIngredientSearchTerm;
  setSelectedIngredientTags: typeof setSelectedIngredientTags;
}

class Landing extends React.PureComponent<ConnectedProps & DispatchProps, void> {
  render() {
    return (
      <div className='landing'>
        <TitleBar>Whaddaya want?</TitleBar>
        <SearchBar
          onChange={this.props.setIngredientSearchTerm}
          value={this.props.ingredientSearchTerm}
          // TODO: Search recipes, their ingredients, and maybe even similar drinks here too!
          placeholder='Ingredient name...'
        />
        <BlurOverlay
          foreground={this.props.ingredientSearchTerm
            ? <GroupedIngredientList
                groupedIngredients={this.props.filteredGroupedIngredients}
                selectedIngredientTags={this.props.selectedIngredientTags}
                onSelectionChange={this._selectIngredient}
              />
            : null}
          background={<RecipeView recipe={sample(this.props.recipesById)}/>}
        />
      </div>
    );
  }

  private _selectIngredient = (tags: string[]) => {
    assert(tags.length === 1); // There is no enforcement that this is the case in this component. We know the parent does this though.
    this.props.setIngredientSearchTerm('');
    this.props.setSelectedIngredientTags(tags);
  };
}

function mapStateToProps(state: RootState): ConnectedProps {
  return {
    recipesById: state.recipes.recipesById,
    ingredientSearchTerm: state.filters.ingredientSearchTerm,
    selectedIngredientTags: state.filters.selectedIngredientTags,
    filteredGroupedIngredients: selectFilteredGroupedIngredients(state)
  };
}

function mapDispatchToProps(dispatch: Dispatch<RootState>): DispatchProps {
  return bindActionCreators({
    setIngredientSearchTerm,
    setSelectedIngredientTags
   }, dispatch);
}

export default connect(mapStateToProps, mapDispatchToProps)(Landing) as React.ComponentClass<void>;
