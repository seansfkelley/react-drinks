
import * as React from 'react';
import * as PureRenderMixin from 'react-addons-pure-render-mixin';

import ReduxMixin from '../mixins/ReduxMixin';
import DerivedValueMixin from '../mixins/DerivedValueMixin';

import { GroupedIngredients } from '../types';
import { store } from '../store';

import SearchBar from '../components/SearchBar';
import GroupedIngredientList from '../ingredients/GroupedIngredientList';

interface Props {
  onClose: () => void;
}

interface State {
  selectedIngredientTags: string[];
  filteredGroupedIngredients: GroupedIngredients[];
}

export default React.createClass<Props, State>({
  displayName: 'IngredientsSidebar',

  mixins: [
    ReduxMixin({
      filters: 'selectedIngredientTags'
    }),
    DerivedValueMixin('filteredGroupedIngredients'),
    PureRenderMixin
  ],

  render() {
    return (
      <div className='ingredients-sidebar'>
        <SearchBar placeholder='Ingredient name...' onChange={this._onSearch} />
        <GroupedIngredientList
          groupedIngredients={this.state.filteredGroupedIngredients}
          initialSelectedIngredientTags={this.state.selectedIngredientTags}
          onSelectionChange={this._onIngredientToggle}
          ref='ingredientList'
        />
      </div>
    );
  },

  _onSearch(searchTerm: string) {
    store.dispatch({
      type: 'set-ingredient-search-term',
      searchTerm
    });
  },

  forceClose() {
    store.dispatch({
      type: 'set-selected-ingredient-tags',
      tags: this.refs.ingredientList.getSelectedTags()
    });
    this.props.onClose();
  }
});


