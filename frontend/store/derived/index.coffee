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

  mixabilityByRecipeId :
    fn            : require './mixabilityByRecipeId'
    stateSelector :
      ingredientsByTag : 'ingredients.ingredientsByTag'
      recipes          : 'recipes.alphabeticalRecipes'
      ingredientTags   : 'filters.selectedIngredientTags'

  filteredGroupedIngredients :
    fn            : require './filteredGroupedIngredients'
    stateSelector :
      groupedIngredients : 'ingredients.groupedIngredients'
      searchTerm         : 'filters.ingredientSearchTerm'
}

module.exports = _.mapValues DERIVED_FUNCTIONS, ({ fn, stateSelector }) ->
  return (state) -> fn.memoized select(state, stateSelector)
