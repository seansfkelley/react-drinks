_ = require 'lodash'

select = require './select'

DERIVED_FUNCTIONS = {
  filteredGroupedRecipes :
    fn            : require './filteredGroupedRecipes'
    stateSelector :
      ingredientsByTag  : 'ingredients.ingredientsByTag'
      recipes           : 'recipes.alphabeticalRecipes'
      baseLiquorFilter  : 'filters.baseLiquorFilter'
      searchTerm        : 'filters.recipeSearchTerm'
      mixabilityFilters : 'filters.mixabilityFilters'
      ingredientTags    : 'filters.selectedIngredientTags'

  ingredientSplitsByRecipeId :
    fn            : require './ingredientSplitsByRecipeId'
    stateSelector :
      recipes          : 'recipes.alphabeticalRecipes'
      ingredientsByTag : 'ingredients.ingredientsByTag'
      ingredientTags   : 'filters.selectedIngredientTags'

  filteredGroupedIngredients :
    fn            : require './filteredGroupedIngredients'
    stateSelector :
      groupedIngredients : 'ingredients.groupedIngredients'
      searchTerm         : 'filters.ingredientSearchTerm'
}

module.exports = _.mapValues DERIVED_FUNCTIONS, ({ fn, stateSelector }) ->
  return (state) -> fn.memoized select(state, stateSelector)
