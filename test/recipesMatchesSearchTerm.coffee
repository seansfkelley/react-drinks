recipeMatchesSearchTerm = require '../frontend/store/derived/recipeMatchesSearchTerm'

searchableIngredient = (tag, searchable...) ->
  return { tag, searchable }

searchableRecipe = (canonicalName, ingredients...) ->
  return { canonicalName, ingredients }

makeIngredientsByTag = (array) ->
  ingredientsByTag = {}
  for i in array
    ingredientsByTag[i.tag] = i
  return ingredientsByTag

describe 'recipeMatchesSearchTerm', ->
  ONE = searchableIngredient 'ingredient-1', '1', 'one'
  TWO = searchableIngredient 'ingredient-2', '2', 'two'

  ingredientsByTag = makeIngredientsByTag [ ONE, TWO ]

  context 'should return true', ->
    context 'when given a single-word search term', ->
      it 'that is a substring of the recipe name', ->
        recipeMatchesSearchTerm({
          recipe     : searchableRecipe('recipe name')
          searchTerm : 'recipe'
          ingredientsByTag
        }).should.be.true

      it 'that is a substring of a searchable term of a recipe ingredient', ->
        recipeMatchesSearchTerm({
          recipe     : searchableRecipe('recipe name', ONE)
          searchTerm : 'one'
          ingredientsByTag
        }).should.be.true

    context 'when given a space-delimited search term', ->
      it 'where all space-delimited terms are substrings of searchable terms of one ingredient', ->
        recipeMatchesSearchTerm({
          recipe     : searchableRecipe('recipe name', ONE)
          searchTerm : 'one 1'
          ingredientsByTag
        }).should.be.true

      it 'where all space-delimited terms are substrings of searchable terms of multiple ingredients', ->
        recipeMatchesSearchTerm({
          recipe     : searchableRecipe('recipe name', ONE, TWO)
          searchTerm : 'one two'
          ingredientsByTag
        }).should.be.true

      it 'where all space-delimited terms are substrings of a searchable term or the title', ->
        recipeMatchesSearchTerm({
          recipe     : searchableRecipe('recipe name', ONE)
          searchTerm : 'one name'
          ingredientsByTag
        }).should.be.true

  context 'should return false', ->
    it 'when given a string of all whitespace', ->
      recipeMatchesSearchTerm({
        recipe     : searchableRecipe('recipe name')
        searchTerm :  ' '
        ingredientsByTag
      }).should.be.false

    it 'when given a space-delimited search term where only one of the two terms are substrings of a searchable term', ->
      recipeMatchesSearchTerm({
        recipe     : searchableRecipe('recipe name', ONE, TWO)
        searchTerm : 'one three'
        ingredientsByTag
      }).should.be.false
