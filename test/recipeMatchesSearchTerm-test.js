const recipeMatchesSearchTerm = require('../frontend/store/derived/recipeMatchesSearchTerm');

const searchableIngredient = (tag, ...searchable) => ({ tag, searchable });

const searchableRecipe = (canonicalName, ...ingredients) => ({ canonicalName, ingredients });

const makeIngredientsByTag = function(array) {
  const ingredientsByTag = {};
  for (let i of array) {
    ingredientsByTag[i.tag] = i;
  }
  return ingredientsByTag;
};

describe('recipeMatchesSearchTerm', function() {
  const ONE = searchableIngredient('ingredient-1', '1', 'one');
  const TWO = searchableIngredient('ingredient-2', '2', 'two');

  const ingredientsByTag = makeIngredientsByTag([ ONE, TWO ]);

  context('should return true', function() {
    context('when given a single-word search term', function() {
      it('that is a substring of the recipe name', () =>
        recipeMatchesSearchTerm({
          recipe     : searchableRecipe('recipe name'),
          searchTerm : 'recipe',
          ingredientsByTag
        }).should.be.true
      );

      return it('that is a substring of a searchable term of a recipe ingredient', () =>
        recipeMatchesSearchTerm({
          recipe     : searchableRecipe('recipe name', ONE),
          searchTerm : 'one',
          ingredientsByTag
        }).should.be.true
      );
    });

    return context('when given a space-delimited search term', function() {
      it('where all space-delimited terms are substrings of searchable terms of one ingredient', () =>
        recipeMatchesSearchTerm({
          recipe     : searchableRecipe('recipe name', ONE),
          searchTerm : 'one 1',
          ingredientsByTag
        }).should.be.true
      );

      it('where all space-delimited terms are substrings of searchable terms of multiple ingredients', () =>
        recipeMatchesSearchTerm({
          recipe     : searchableRecipe('recipe name', ONE, TWO),
          searchTerm : 'one two',
          ingredientsByTag
        }).should.be.true
      );

      return it('where all space-delimited terms are substrings of a searchable term or the title', () =>
        recipeMatchesSearchTerm({
          recipe     : searchableRecipe('recipe name', ONE),
          searchTerm : 'one name',
          ingredientsByTag
        }).should.be.true
      );
    });
  });

  return context('should return false', function() {
    it('when given a string of all whitespace', () =>
      recipeMatchesSearchTerm({
        recipe     : searchableRecipe('recipe name'),
        searchTerm :  ' ',
        ingredientsByTag
      }).should.be.false
    );

    return it('when given a space-delimited search term where only one of the two terms are substrings of a searchable term', () =>
      recipeMatchesSearchTerm({
        recipe     : searchableRecipe('recipe name', ONE, TWO),
        searchTerm : 'one three',
        ingredientsByTag
      }).should.be.false
    );
  });
});
