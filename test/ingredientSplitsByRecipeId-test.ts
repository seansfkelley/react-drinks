import { expect } from 'chai';
import { omit } from 'lodash';

import { makePartialProxy } from './testUtils';
import { Ingredient, Recipe, DisplayIngredient } from '../shared/types';
import {
  _countSubsetMissing,
  _includeAllGenerics,
  _toMostGenericTags,
  _computeSubstitutionMap,
  ingredientSplitsByRecipeId
} from '../frontend/store/derived/ingredientSplitsByRecipeId';

function makeIngredientsByTag(array: Ingredient[]) {
  const ingredientsByTag: { [tag: string]: Ingredient } = {};
  array.forEach(i => {
    ingredientsByTag[i.tag] = i;
  });
  return ingredientsByTag;
};

function indexableIngredient(tag?: string, generic?: string): Ingredient {
  const display = `name-${tag}`;
  return makePartialProxy<Ingredient>({ tag, generic, display });
};

function resultIngredient(tag?: string): Ingredient {
  const display = `name-${tag}`;
  return makePartialProxy<Ingredient>({ tag, display });
}

const IndexableIngredient = {
  A_ROOT: indexableIngredient('a'),
  A_CHILD_1: indexableIngredient('a-1', 'a'),
  A_CHILD_1_1: indexableIngredient('a-1-1', 'a-1'),
  A_CHILD_2: indexableIngredient('a-2', 'a'),
  A_CHILD_3: indexableIngredient('a-3', 'a'),
  B_ROOT: indexableIngredient('b'),
  Z_ROOT: indexableIngredient('z'),
  NULL: indexableIngredient()
};

const ResultIngredient = {
  A_ROOT: resultIngredient('a'),
  A_CHILD_1: resultIngredient('a-1'),
  A_CHILD_1_1: resultIngredient('a-1-1'),
  A_CHILD_2: resultIngredient('a-2'),
  A_CHILD_3: resultIngredient('a-3'),
  B_ROOT: resultIngredient('b'),
  Z_ROOT: resultIngredient('z'),
  NULL: resultIngredient()
};

describe('ingredientSplitsByRecipeId', () => {
  describe('#_includeAllGenerics', () => {
    const ingredientsByTag = makeIngredientsByTag([IndexableIngredient.A_ROOT, IndexableIngredient.A_CHILD_1, IndexableIngredient.A_CHILD_1_1, IndexableIngredient.A_CHILD_2]);

    it('should return an input ingredient with no generic', () => {
      expect(_includeAllGenerics({
        ingredients: [IndexableIngredient.A_ROOT],
        ingredientsByTag
      })).to.have.members([IndexableIngredient.A_ROOT]);
    });

    it('should return an ingredient and its single generic', () => {
      expect(_includeAllGenerics({
        ingredients: [IndexableIngredient.A_CHILD_1],
        ingredientsByTag
      })).to.have.members([IndexableIngredient.A_ROOT, IndexableIngredient.A_CHILD_1]);
    });

    it('should return an ingredient and its multiple generics', () => {
      expect(_includeAllGenerics({
        ingredients: [IndexableIngredient.A_CHILD_1_1],
        ingredientsByTag
      })).to.have.members([IndexableIngredient.A_ROOT, IndexableIngredient.A_CHILD_1, IndexableIngredient.A_CHILD_1_1]);
    });

    it('should not return any duplicates if multiple ingredients are the same', () => {
      expect(_includeAllGenerics({
        ingredients: [IndexableIngredient.A_ROOT, IndexableIngredient.A_ROOT],
        ingredientsByTag
      })).to.have.members([IndexableIngredient.A_ROOT]);
    });

    it('should not return any duplicates if multiple ingredients have the same generic', () => {
      expect(_includeAllGenerics({
        ingredients: [IndexableIngredient.A_CHILD_1, IndexableIngredient.A_CHILD_2],
        ingredientsByTag
      })).to.have.members([IndexableIngredient.A_ROOT, IndexableIngredient.A_CHILD_1, IndexableIngredient.A_CHILD_2]);
    });
  });

  describe('#_toMostGenericTags', () => {
    const ingredientsByTag = makeIngredientsByTag([IndexableIngredient.A_ROOT, IndexableIngredient.A_CHILD_1, IndexableIngredient.A_CHILD_1_1, IndexableIngredient.A_CHILD_2]);

    it('should return the tag of an ingredient with no generic', () => {
      expect(_toMostGenericTags({
        ingredients: [IndexableIngredient.A_ROOT],
        ingredientsByTag
      })).to.have.members([IndexableIngredient.A_ROOT.tag]);
    });

    it('should return the tag of a generic of an ingredient', () => {
      expect(_toMostGenericTags({
        ingredients: [IndexableIngredient.A_CHILD_1],
        ingredientsByTag
      })).to.have.members([IndexableIngredient.A_ROOT.tag]);
    });

    it('should return the tag of the most generic ancestor of an ingredient', () => {
      expect(_toMostGenericTags({
        ingredients: [IndexableIngredient.A_CHILD_1_1],
        ingredientsByTag
      })).to.have.members([IndexableIngredient.A_ROOT.tag]);
    });

    it('should not return any duplicates if multiple ingredients are the same', () => {
      expect(_toMostGenericTags({
        ingredients: [IndexableIngredient.A_ROOT, IndexableIngredient.A_ROOT],
        ingredientsByTag
      })).to.have.members([IndexableIngredient.A_ROOT.tag]);
    });

    return it('should not return any duplicates if multiple ingredients have the same generic', () => {
      expect(_toMostGenericTags({
        ingredients: [IndexableIngredient.A_CHILD_1, IndexableIngredient.A_CHILD_2],
        ingredientsByTag
      })).to.have.members([IndexableIngredient.A_ROOT.tag]);
    });
  });

  describe('#_computeSubstitutionMap', () => {
    const ingredientsByTag = makeIngredientsByTag([IndexableIngredient.A_ROOT, IndexableIngredient.A_CHILD_1, IndexableIngredient.A_CHILD_1_1, IndexableIngredient.A_CHILD_1_1]);

    it('should return a map from an ingredient to itself when given an ingredient with no generic', () => {
      expect(_computeSubstitutionMap({
        ingredients: [IndexableIngredient.A_ROOT],
        ingredientsByTag
      })).to.deep.equal({
        [IndexableIngredient.A_ROOT.tag]: [IndexableIngredient.A_ROOT.tag]
      });
    });

    it('should return a map that includes direct descendants in their generic\'s entry when both are given', () => {
      expect(_computeSubstitutionMap({
        ingredients: [IndexableIngredient.A_ROOT, IndexableIngredient.A_CHILD_1],
        ingredientsByTag
      })).to.deep.equal({
        [IndexableIngredient.A_ROOT.tag]: [IndexableIngredient.A_ROOT.tag, IndexableIngredient.A_CHILD_1.tag],
        [IndexableIngredient.A_CHILD_1.tag]: [IndexableIngredient.A_CHILD_1.tag]
      });
    });

    it('should not include an inferred generic\'s tag as a value if that generic was not given', () => {
      expect(_computeSubstitutionMap({
        ingredients: [IndexableIngredient.A_CHILD_1],
        ingredientsByTag
      })).to.deep.equal({
        [IndexableIngredient.A_ROOT.tag]: [IndexableIngredient.A_CHILD_1.tag],
        [IndexableIngredient.A_CHILD_1.tag]: [IndexableIngredient.A_CHILD_1.tag]
      });
    });

    it('should return a map where each generic includes all descendant generations\' tags', () => {
      expect(_computeSubstitutionMap({
        ingredients: [IndexableIngredient.A_ROOT, IndexableIngredient.A_CHILD_1, IndexableIngredient.A_CHILD_1_1],
        ingredientsByTag
      })).to.deep.equal({
        [IndexableIngredient.A_ROOT.tag]: [IndexableIngredient.A_ROOT.tag, IndexableIngredient.A_CHILD_1.tag, IndexableIngredient.A_CHILD_1_1.tag],
        [IndexableIngredient.A_CHILD_1.tag]: [IndexableIngredient.A_CHILD_1.tag, IndexableIngredient.A_CHILD_1_1.tag],
        [IndexableIngredient.A_CHILD_1_1.tag]: [IndexableIngredient.A_CHILD_1_1.tag]
      });
    });

    it('should return a map where a generic with multiple descendants includes all their tags', () => {
      expect(_computeSubstitutionMap({
        ingredients: [IndexableIngredient.A_ROOT, IndexableIngredient.A_CHILD_1, IndexableIngredient.A_CHILD_2],
        ingredientsByTag
      })).to.deep.equal({
        [IndexableIngredient.A_ROOT.tag]: [IndexableIngredient.A_ROOT.tag, IndexableIngredient.A_CHILD_1.tag, IndexableIngredient.A_CHILD_2.tag],
        [IndexableIngredient.A_CHILD_1.tag]: [IndexableIngredient.A_CHILD_1.tag],
        [IndexableIngredient.A_CHILD_2.tag]: [IndexableIngredient.A_CHILD_2.tag]
      });
    });
  });

  describe('#_countSubsetMissing', () => {
    it('should return how values in the first array are not in the second', () => {
      expect(_countSubsetMissing([1, 2, 3], [1, 4, 5])).to.equal(2);
    });
  });

  // TODO: Many of these tests are sensitive to the ordering of the nested ingredient
  // arrays. I don't currently see a way in Mocha to get around this without picking
  // the result apart into multiple assertions.
  function makeArgs(ingredientTags: string[] | { [tag: string]: any }, ...recipes: Recipe[]) {
    return {
      recipes,
      ingredientTags,
      ingredientsByTag: makeIngredientsByTag([
        IndexableIngredient.A_ROOT,
        IndexableIngredient.A_CHILD_1,
        IndexableIngredient.A_CHILD_1_1,
        IndexableIngredient.A_CHILD_2,
        IndexableIngredient.A_CHILD_3,
        IndexableIngredient.B_ROOT
      ])
    };
  }

  // This is very important: the recipes that are indexed do NOT have a generic flag.
  function recipe(recipeId: string, ...ingredients: Ingredient[]): Recipe {
    return makePartialProxy<Recipe>({
      name: recipeId,
      recipeId,
      ingredients: ingredients.map(i => omit(i, 'generic') as DisplayIngredient)
    });
  }

  it('should return the empty object when no recipes are given', () => {
    expect(ingredientSplitsByRecipeId(makeArgs([]))).to.be.empty;
  });

  it('should accept ingredientTags as an array of strings', () => {
    expect(ingredientSplitsByRecipeId(makeArgs([IndexableIngredient.A_ROOT.tag], recipe('some-recipe-id', IndexableIngredient.A_ROOT)))).to.not.be.empty;
  });

  it('should accept ingredientTags as a map from strings to anything (i.e. a set)', () => {
    expect(ingredientSplitsByRecipeId(makeArgs({ [IndexableIngredient.A_ROOT.tag]: true }, recipe('some-recipe-id', IndexableIngredient.A_ROOT)))).to.not.be.empty;
  });

  // This is an upgrade consideration, if someone has a tag in localStorage but it's removed in later versions.
  it('should should not throw an exception when given ingredients it doesn\'t understand', () => {
    expect(ingredientSplitsByRecipeId(makeArgs([IndexableIngredient.Z_ROOT.tag]))).to.be.empty;
  });

  it('should return results keyed by recipe ID', () => {
    expect(ingredientSplitsByRecipeId(makeArgs([IndexableIngredient.A_ROOT.tag], recipe('some-recipe-id', IndexableIngredient.A_ROOT)))).to.have.all.keys(['some-recipe-id']);
  });

  it('should return a match for a recipe that matches exactly', () => {
    expect(ingredientSplitsByRecipeId(makeArgs([IndexableIngredient.A_ROOT.tag], recipe('some-recipe-id', IndexableIngredient.A_ROOT)))).to.deep.equal({
      'some-recipe-id': {
        missing: [],
        substitute: [],
        available: [ResultIngredient.A_ROOT]
      }
    });
  });

  it('should consider ingredients without tags always available', () => {
    expect(ingredientSplitsByRecipeId(makeArgs([IndexableIngredient.A_ROOT.tag], recipe('some-recipe-id', IndexableIngredient.A_ROOT, IndexableIngredient.NULL)))).to.deep.equal({
      'some-recipe-id': {
        missing: [],
        substitute: [],
        available: [ResultIngredient.A_ROOT, ResultIngredient.NULL]
      }
    });
  });

  it('should silently ignore input ingredients with no tags', () => {
    expect(ingredientSplitsByRecipeId(makeArgs([IndexableIngredient.A_ROOT.tag], recipe('some-recipe-id', IndexableIngredient.A_ROOT, IndexableIngredient.NULL)))).to.have.all.keys(['some-recipe-id']);
  });

  it('should return an available match for a recipe if it calls for a parent (less specific) ingredient', () => {
    expect(ingredientSplitsByRecipeId(makeArgs([IndexableIngredient.A_CHILD_2.tag], recipe('some-recipe-id', IndexableIngredient.A_ROOT)))).to.deep.equal({
      'some-recipe-id': {
        missing: [],
        substitute: [],
        available: [ResultIngredient.A_ROOT]
      }
    });
  });

  it('should return a substitutable match for a recipe if it calls for a sibling (equally specific) ingredient', () => {
    expect(ingredientSplitsByRecipeId(makeArgs([IndexableIngredient.A_CHILD_2.tag], recipe('some-recipe-id', IndexableIngredient.A_CHILD_1)))).to.deep.equal({
      'some-recipe-id': {
        missing: [],
        substitute: [{
          need: ResultIngredient.A_CHILD_1,
          have: [ResultIngredient.A_CHILD_2.display]
        }],
        available: []
      }
    });
  });

  it('should return a substitutable match for a recipe if it calls for a child (more specific) ingredient', () => {
    expect(ingredientSplitsByRecipeId(makeArgs([IndexableIngredient.A_ROOT.tag], recipe('some-recipe-id', IndexableIngredient.A_CHILD_1)))).to.deep.equal({
      'some-recipe-id': {
        missing: [],
        substitute: [{
          need: ResultIngredient.A_CHILD_1,
          have: [ResultIngredient.A_ROOT.display]
        }],
        available: []
      }
    });
  });

  it('should return multiple substitutable matches for a recipe (with sibling ingredients)', () => {
    expect(ingredientSplitsByRecipeId(makeArgs([IndexableIngredient.A_CHILD_2.tag, IndexableIngredient.A_CHILD_3.tag], recipe('some-recipe-id', IndexableIngredient.A_CHILD_1)))).to.deep.equal({
      'some-recipe-id': {
        missing: [],
        substitute: [{
          need: ResultIngredient.A_CHILD_1,
          have: [ResultIngredient.A_CHILD_2.display, ResultIngredient.A_CHILD_3.display]
        }],
        available: []
      }
    });
  });

  it('should count unknown recipe ingredients as missing', () => {
    expect(ingredientSplitsByRecipeId(makeArgs([IndexableIngredient.A_ROOT.tag], recipe('some-recipe-id', IndexableIngredient.Z_ROOT, IndexableIngredient.A_ROOT)))).to.deep.equal({
      'some-recipe-id': {
        missing: [ResultIngredient.Z_ROOT],
        substitute: [],
        available: [ResultIngredient.A_ROOT]
      }
    });
  });
});
