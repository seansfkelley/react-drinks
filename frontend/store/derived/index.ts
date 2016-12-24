import {} from 'lodash';

const select = require('./select');

const DERIVED_FUNCTIONS = {
  filteredGroupedRecipes: {
    fn: require('./filteredGroupedRecipes'),
    stateSelector: {
      ingredientsByTag: 'ingredients.ingredientsByTag',
      recipes: 'recipes.alphabeticalRecipes',
      baseLiquorFilter: 'filters.baseLiquorFilter',
      searchTerm: 'filters.recipeSearchTerm',
      ingredientTags: 'filters.selectedIngredientTags',
      selectedRecipeList: 'filters.selectedRecipeList',
      favoritedRecipeIds: 'ui.favoritedRecipeIds'
    }
  },

  ingredientSplitsByRecipeId: {
    fn: require('./ingredientSplitsByRecipeId'),
    stateSelector: {
      recipes: 'recipes.alphabeticalRecipes',
      ingredientsByTag: 'ingredients.ingredientsByTag',
      ingredientTags: 'filters.selectedIngredientTags'
    }
  },

  filteredGroupedIngredients: {
    fn: require('./filteredGroupedIngredients'),
    stateSelector: {
      groupedIngredients: 'ingredients.groupedIngredients',
      searchTerm: 'filters.ingredientSearchTerm'
    }
  }
};

module.exports = _.mapValues(DERIVED_FUNCTIONS, ({ fn, stateSelector }) => state => fn.memoized(select(state, stateSelector)));
