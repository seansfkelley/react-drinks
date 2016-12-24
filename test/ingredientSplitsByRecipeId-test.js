const _ = require('lodash');

const ingredientSplitsByRecipeId = require('../frontend/store/derived/ingredientSplitsByRecipeId');

const { _countSubsetMissing,
  _includeAllGenerics,
  _toMostGenericTags,
  _computeSubstitutionMap,
  _generateSearchResult } = ingredientSplitsByRecipeId.__test;

const makeIngredientsByTag = function(array) {
  const ingredientsByTag = {};
  for (let i of array) {
    ingredientsByTag[i.tag] = i;
  }
  return ingredientsByTag;
};

const ingredient = function(tag, generic = null) {
  const display = `name-${tag}`;
  return { tag, generic, display };
};

const IndexableIngredient = {
  A_ROOT      : ingredient('a'),
  A_CHILD_1   : ingredient('a-1', 'a'),
  A_CHILD_1_1 : ingredient('a-1-1', 'a-1'),
  A_CHILD_2   : ingredient('a-2', 'a'),
  A_CHILD_3   : ingredient('a-3', 'a'),
  B_ROOT      : ingredient('b'),
  Z_ROOT      : ingredient('z'),
  NULL        : ingredient()
};

const ResultIngredient = _.mapValues(IndexableIngredient, i => _.omit(i, 'generic'));

describe('ingredientSplitsByRecipeId', function() {
  describe('#_includeAllGenerics', function() {
    const ingredientsByTag = makeIngredientsByTag([
      IndexableIngredient.A_ROOT,
      IndexableIngredient.A_CHILD_1,
      IndexableIngredient.A_CHILD_1_1,
      IndexableIngredient.A_CHILD_2
    ]);

    it('should return an input ingredient with no generic', () =>
      _includeAllGenerics({
        ingredients : [ IndexableIngredient.A_ROOT ],
        ingredientsByTag
      }).should.have.members([
        IndexableIngredient.A_ROOT
      ]));

    it('should return an ingredient and its single generic', () =>
      _includeAllGenerics({
        ingredients : [ IndexableIngredient.A_CHILD_1 ],
        ingredientsByTag
      }).should.have.members([
        IndexableIngredient.A_ROOT,
        IndexableIngredient.A_CHILD_1
      ]));

    it('should return an ingredient and its multiple generics', () =>
      _includeAllGenerics({
        ingredients : [ IndexableIngredient.A_CHILD_1_1 ],
        ingredientsByTag
      }).should.have.members([
        IndexableIngredient.A_ROOT,
        IndexableIngredient.A_CHILD_1,
        IndexableIngredient.A_CHILD_1_1
      ]));

    it('should not return any duplicates if multiple ingredients are the same', () =>
      _includeAllGenerics({
        ingredients : [ IndexableIngredient.A_ROOT, IndexableIngredient.A_ROOT ],
        ingredientsByTag
      }).should.have.members([
        IndexableIngredient.A_ROOT
      ]));

    return it('should not return any duplicates if multiple ingredients have the same generic', () =>
      _includeAllGenerics({
        ingredients : [ IndexableIngredient.A_CHILD_1, IndexableIngredient.A_CHILD_2 ],
        ingredientsByTag
      }).should.have.members([
        IndexableIngredient.A_ROOT,
        IndexableIngredient.A_CHILD_1,
        IndexableIngredient.A_CHILD_2
      ]));});

  describe('#_toMostGenericTags', function() {
    const ingredientsByTag = makeIngredientsByTag([
      IndexableIngredient.A_ROOT,
      IndexableIngredient.A_CHILD_1,
      IndexableIngredient.A_CHILD_1_1,
      IndexableIngredient.A_CHILD_2
    ]);

    it('should return the tag of an ingredient with no generic', () =>
      _toMostGenericTags({
        ingredients : [ IndexableIngredient.A_ROOT ],
        ingredientsByTag
      }).should.have.members([
        IndexableIngredient.A_ROOT.tag
      ]));

    it('should return the tag of a generic of an ingredient', () =>
      _toMostGenericTags({
        ingredients : [ IndexableIngredient.A_CHILD_1 ],
        ingredientsByTag
      }).should.have.members([
        IndexableIngredient.A_ROOT.tag
      ]));

    it('should return the tag of the most generic ancestor of an ingredient', () =>
      _toMostGenericTags({
        ingredients : [ IndexableIngredient.A_CHILD_1_1 ],
        ingredientsByTag
      }).should.have.members([
        IndexableIngredient.A_ROOT.tag
      ]));

    it('should not return any duplicates if multiple ingredients are the same', () =>
      _toMostGenericTags({
        ingredients : [ IndexableIngredient.A_ROOT, IndexableIngredient.A_ROOT ],
        ingredientsByTag
      }).should.have.members([
        IndexableIngredient.A_ROOT.tag
      ]));

    return it('should not return any duplicates if multiple ingredients have the same generic', () =>
      _toMostGenericTags({
        ingredients : [ IndexableIngredient.A_CHILD_1, IndexableIngredient.A_CHILD_2 ],
        ingredientsByTag
      }).should.have.members([
        IndexableIngredient.A_ROOT.tag
      ]));});

  describe('#_computeSubstitutionMap', function() {
    const ingredientsByTag = makeIngredientsByTag([
      IndexableIngredient.A_ROOT,
      IndexableIngredient.A_CHILD_1,
      IndexableIngredient.A_CHILD_1_1,
      IndexableIngredient.A_CHILD_1_1
    ]);

    it('should return a map from an ingredient to itself when given an ingredient with no generic', () =>
      _computeSubstitutionMap({
        ingredients : [ IndexableIngredient.A_ROOT ],
        ingredientsByTag
      }).should.deep.equal({
        [IndexableIngredient.A_ROOT.tag] : [ IndexableIngredient.A_ROOT.tag ]
      }));

    it('should return a map that includes direct descendants in their generic\'s entry when both are given', () =>
      _computeSubstitutionMap({
        ingredients : [ IndexableIngredient.A_ROOT, IndexableIngredient.A_CHILD_1 ],
        ingredientsByTag
      }).should.deep.equal({
        [IndexableIngredient.A_ROOT.tag]    : [ IndexableIngredient.A_ROOT.tag, IndexableIngredient.A_CHILD_1.tag ],
        [IndexableIngredient.A_CHILD_1.tag] : [ IndexableIngredient.A_CHILD_1.tag ]
      }));

    it('should not include an inferred generic\'s tag as a value if that generic was not given', () =>
      _computeSubstitutionMap({
        ingredients : [ IndexableIngredient.A_CHILD_1 ],
        ingredientsByTag
      }).should.deep.equal({
        [IndexableIngredient.A_ROOT.tag]    : [ IndexableIngredient.A_CHILD_1.tag ],
        [IndexableIngredient.A_CHILD_1.tag] : [ IndexableIngredient.A_CHILD_1.tag ]
      }));

    it('should return a map where each generic includes all descendant generations\' tags', () =>
      _computeSubstitutionMap({
        ingredients : [
          IndexableIngredient.A_ROOT,
          IndexableIngredient.A_CHILD_1,
          IndexableIngredient.A_CHILD_1_1
        ],
        ingredientsByTag
      }).should.deep.equal({
        [IndexableIngredient.A_ROOT.tag] : [
          IndexableIngredient.A_ROOT.tag,
          IndexableIngredient.A_CHILD_1.tag,
          IndexableIngredient.A_CHILD_1_1.tag
        ],
        [IndexableIngredient.A_CHILD_1.tag] : [
          IndexableIngredient.A_CHILD_1.tag,
          IndexableIngredient.A_CHILD_1_1.tag
        ],
        [IndexableIngredient.A_CHILD_1_1.tag] : [
          IndexableIngredient.A_CHILD_1_1.tag
        ]
      }));

    return it('should return a map where a generic with multiple descendants includes all their tags', () =>
      _computeSubstitutionMap({
        ingredients : [
          IndexableIngredient.A_ROOT,
          IndexableIngredient.A_CHILD_1,
          IndexableIngredient.A_CHILD_2
        ],
        ingredientsByTag
      }).should.deep.equal({
        [IndexableIngredient.A_ROOT.tag] : [
          IndexableIngredient.A_ROOT.tag,
          IndexableIngredient.A_CHILD_1.tag,
          IndexableIngredient.A_CHILD_2.tag
        ],
        [IndexableIngredient.A_CHILD_1.tag] : [
          IndexableIngredient.A_CHILD_1.tag
        ],
        [IndexableIngredient.A_CHILD_2.tag] : [
          IndexableIngredient.A_CHILD_2.tag
        ]
      }));});

  describe('#_countSubsetMissing', () =>
    it('should return how values in the first array are not in the second', () => _countSubsetMissing([ 1, 2, 3 ], [ 1, 4, 5 ]).should.equal(2))
  );

  // TODO: Many of these tests are sensitive to the ordering of the nested ingredient
  // arrays. I don't currently see a way in Mocha to get around this without picking
  // the result apart into multiple assertions.
  const makeArgs = (ingredientTags, ...recipes) => ({
    recipes,
    ingredientTags,
    ingredientsByTag : makeIngredientsByTag([
      IndexableIngredient.A_ROOT,
      IndexableIngredient.A_CHILD_1,
      IndexableIngredient.A_CHILD_1_1,
      IndexableIngredient.A_CHILD_2,
      IndexableIngredient.A_CHILD_3,
      IndexableIngredient.B_ROOT
    ])
  }) ;

  const recipe = (recipeId, ...ingredients) =>
    // This is very important: the recipes that are indexed do NOT have a generic flag.
    ({
      recipeId,
      ingredients : _.map(ingredients, i => _.omit(i, 'generic'))
    })
  ;

  it('should return the empty object when no recipes are given', () => ingredientSplitsByRecipeId(makeArgs([])).should.be.empty);

  it('should accept ingredientTags as an array of strings', () =>
    ingredientSplitsByRecipeId(makeArgs(
      [ IndexableIngredient.A_ROOT.tag ],
      recipe(null, IndexableIngredient.A_ROOT)
    )).should.not.be.empty
  );

  it('should accept ingredientTags as a map from strings to anything (i.e. a set)', () =>
    ingredientSplitsByRecipeId(makeArgs(
      { [IndexableIngredient.A_ROOT.tag] : true },
      recipe(null, IndexableIngredient.A_ROOT)
    )).should.not.be.empty
  );

  // This is an upgrade consideration, if someone has a tag in localStorage but it's removed in later versions.
  it('should should not throw an exception when given ingredients it doesn\'t understand', () =>
    ingredientSplitsByRecipeId(makeArgs(
      [ IndexableIngredient.Z_ROOT.tag ]
    )).should.be.empty
  );

  it('should return results keyed by recipe ID', () =>
    ingredientSplitsByRecipeId(makeArgs(
      [ IndexableIngredient.A_ROOT.tag ],
      recipe('abc', IndexableIngredient.A_ROOT)
    )).should.have.all.keys([ 'abc' ]));

  it('should return a match for a recipe that matches exactly', () =>
    ingredientSplitsByRecipeId(makeArgs(
      [ IndexableIngredient.A_ROOT.tag ],
      recipe(1, IndexableIngredient.A_ROOT)
    )).should.deep.equal({
      '1' : {
        missing    : [],
        substitute : [],
        available  : [ ResultIngredient.A_ROOT ]
      }
    }));

  it('should consider ingredients without tags always available', () =>
    ingredientSplitsByRecipeId(makeArgs(
      [ IndexableIngredient.A_ROOT.tag ],
      recipe(1, IndexableIngredient.A_ROOT, IndexableIngredient.NULL)
    )).should.deep.equal({
      '1' : {
        missing    : [],
        substitute : [],
        available  : [ ResultIngredient.A_ROOT, ResultIngredient.NULL ]
      }
    }));

  it('should silently ignore input ingredients with no tags', () =>
    ingredientSplitsByRecipeId(makeArgs(
      [ IndexableIngredient.A_ROOT.tag ],
      recipe(1, IndexableIngredient.A_ROOT, IndexableIngredient.NULL)
    )).should.have.all.keys([ '1' ]));

  it('should return an available match for a recipe if it calls for a parent (less specific) ingredient', () =>
    ingredientSplitsByRecipeId(makeArgs(
      [ IndexableIngredient.A_CHILD_2.tag ],
      recipe(1, IndexableIngredient.A_ROOT)
    )).should.deep.equal({
      '1' : {
        missing     : [],
        substitute  : [],
        available   : [ ResultIngredient.A_ROOT ]
      }
    }));

  it('should return a substitutable match for a recipe if it calls for a sibling (equally specific) ingredient', () =>
    ingredientSplitsByRecipeId(makeArgs(
      [ IndexableIngredient.A_CHILD_2.tag ],
      recipe(1, IndexableIngredient.A_CHILD_1)
    )).should.deep.equal({
      '1' : {
        missing     : [],
        substitute  : [{
          need : ResultIngredient.A_CHILD_1,
          have : [ ResultIngredient.A_CHILD_2.display ]
        }],
        available   : []
      }
    }));

  it('should return a substitutable match for a recipe if it calls for a child (more specific) ingredient', () =>
    ingredientSplitsByRecipeId(makeArgs(
      [ IndexableIngredient.A_ROOT.tag ],
      recipe(1, IndexableIngredient.A_CHILD_1)
    )).should.deep.equal({
      '1' : {
        missing     : [],
        substitute  : [{
          need : ResultIngredient.A_CHILD_1,
          have : [ ResultIngredient.A_ROOT.display ]
        }],
        available   : []
      }
    }));

  it('should return multiple substitutable matches for a recipe (with sibling ingredients)', () =>
    ingredientSplitsByRecipeId(makeArgs(
      [ IndexableIngredient.A_CHILD_2.tag, IndexableIngredient.A_CHILD_3.tag ],
      recipe(1, IndexableIngredient.A_CHILD_1)
    )).should.deep.equal({
      '1' : {
        missing     : [],
        substitute  : [{
          need : ResultIngredient.A_CHILD_1,
          have : [ ResultIngredient.A_CHILD_2.display, ResultIngredient.A_CHILD_3.display ]
        }],
        available   : []
      }
    }));

  return it('should count unknown recipe ingredients as missing', () =>
    ingredientSplitsByRecipeId(makeArgs(
      [ IndexableIngredient.A_ROOT.tag ],
      recipe(1, IndexableIngredient.Z_ROOT, IndexableIngredient.A_ROOT)
    )).should.deep.equal({
      '1' : {
        missing    : [ ResultIngredient.Z_ROOT ],
        substitute : [],
        available  : [ ResultIngredient.A_ROOT ]
      }
    }));});
