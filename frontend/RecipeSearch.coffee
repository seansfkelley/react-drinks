_countSubset = (small, large) ->
  missed = 0
  for s in small
    if s not in large
      missed++
  return missed

class RecipeSearch
  constructor : (recipes) ->
    @_recipesForIngredientTags = {}
    for r in recipes
      for tag in r.searchableIngredients
        (@_recipesForIngredientTags[tag] ?= []).push r
    return # for loop

  computeMixableRecipes : (ingredientTags, flex = 0) ->
    return _.chain ingredientTags
      .map (tag) => @_recipesForIngredientTags[tag]
      .compact()
      .flatten()
      .sortBy 'normalizedName'
      .uniq (r) -> r.normalizedName
      .map (r) -> _.extend { missing : _countSubset(r.searchableIngredients, ingredientTags) }, r
      .filter (r) -> r.missing <= flex
      .groupBy 'missing'
      .value()

module.exports = RecipeSearch
