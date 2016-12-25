import { expect } from 'chai';

import { makePartialProxy } from './testUtils';
import { Ingredient, Recipe } from '../shared/types';
import { recipeMatchesSearchTerm } from '../frontend/store/derived/recipeMatchesSearchTerm';

function searchableIngredient(tag: string, ...searchable: string[]): Ingredient {
  return makePartialProxy<Ingredient>({ tag, searchable });
}

function searchableRecipe(canonicalName: string, ...ingredients: Ingredient[]): Recipe {
  return makePartialProxy<Recipe>({ canonicalName, ingredients: ingredients.map(i => ({ tag: i.tag, displayIngredient: i.tag })) });
}

function makeIngredientsByTag(array: Ingredient[]) {
  const ingredientsByTag: { [tag: string]: Ingredient } = {};
  array.forEach(i => {
    ingredientsByTag[i.tag] = i;
  });
  return ingredientsByTag;
};

describe('recipeMatchesSearchTerm', () => {
  const ONE = searchableIngredient('ingredient-1', '1', 'one');
  const TWO = searchableIngredient('ingredient-2', '2', 'two');

  const ingredientsByTag = makeIngredientsByTag([ONE, TWO]);

  context('should return true', () => {
    context('when given a single-word search term', () => {
      it('that is a substring of the recipe name', () => {
        expect(recipeMatchesSearchTerm({
          recipe: searchableRecipe('recipe name'),
          searchTerm: 'recipe',
          ingredientsByTag
        })).to.be.true;
      });

      it('that is a substring of a searchable term of a recipe ingredient', () => {
        expect(recipeMatchesSearchTerm({
          recipe: searchableRecipe('recipe name', ONE),
          searchTerm: 'one',
          ingredientsByTag
        })).to.be.true;
      });
    });

    context('when given a space-delimited search term', () => {
      it('where all space-delimited terms are substrings of searchable terms of one ingredient', () => {
        expect(recipeMatchesSearchTerm({
          recipe: searchableRecipe('recipe name', ONE),
          searchTerm: 'one 1',
          ingredientsByTag
        })).to.be.true;
      });

      it('where all space-delimited terms are substrings of searchable terms of multiple ingredients', () => {
        expect(recipeMatchesSearchTerm({
          recipe: searchableRecipe('recipe name', ONE, TWO),
          searchTerm: 'one two',
          ingredientsByTag
        })).to.be.true;
      });

      it('where all space-delimited terms are substrings of a searchable term or the title', () => {
        expect(recipeMatchesSearchTerm({
          recipe: searchableRecipe('recipe name', ONE),
          searchTerm: 'one name',
          ingredientsByTag
        })).to.be.true;
      });
    });
  });

  context('should return false', () => {
    it('when given a string of all whitespace', () => {
      expect(recipeMatchesSearchTerm({
        recipe: searchableRecipe('recipe name'),
        searchTerm: ' ',
        ingredientsByTag
      })).to.be.false;
    });

    it('when given a space-delimited search term where only one of the two terms are substrings of a searchable term', () => {
      expect(recipeMatchesSearchTerm({
        recipe: searchableRecipe('recipe name', ONE, TWO),
        searchTerm: 'one three',
        ingredientsByTag
      })).to.be.false;
    });
  });
});

