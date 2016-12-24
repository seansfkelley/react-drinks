const _           = require('lodash');
const fs          = require('fs');
const yaml        = require('js-yaml');
const revalidator = require('revalidator');
const log         = require('loglevel');

const normalization = require('../shared/normalization');
const definitions   = require('../shared/definitions');

const revalidatorUtils = require('./revalidator-utils');
const { REQUIRED_STRING, OPTIONAL_STRING } = revalidatorUtils;

const xor = (a, b) => (a || b) && !(a && b);

const BASE_LIQUORS = [ definitions.UNASSIGNED_BASE_LIQUOR ].concat(definitions.BASE_LIQUORS);

const INGREDIENT_SCHEMA = {
  type       : 'object',
  properties : {
    // The display name of the ingredient.
    display : REQUIRED_STRING,
    // The category this ingredient is in (e.g., spirit, mixer, syrup...)
    group : {
      type    : 'string',
      conform(v, object) { return xor((v != null), !(object.tangible != null ? object.tangible : true)); }
    },
    // Intangible ingredients are useful to index on or specify, but are not specific enough to
    // warrant being something you can have in your cabinet. The canonical example is Chartreuse
    // (either variety), but it's also useful for e.g whiskey as a generic.
    tangible : {
      type    : 'boolean',
      conform(v, object) { return xor(!(v != null ? v : true), (object.group != null)); }
    },
    // The uniquely identifying tag for this ingredient. Defaults to the lowercase display name.
    tag : OPTIONAL_STRING,
    // The tag for the generic (substitutable) ingredient for this ingredient. If the target doesn't
    // exist, a new invisible ingredient is added.
    generic : OPTIONAL_STRING,
    // An approximate rating for how difficult this ingredient is to buy.
    difficulty : {
      type : 'string',
      enum : [ 'easy', 'medium', 'hard' ]
    },
    // An array of searchable terms for the ingredient. Includes the display name of itself and its
    // generic (if it exists) by default.
    searchable : {
      type     : 'array',
      required : false,
      items : {
        type : 'string'
      }
    }
  }
};

const RECIPE_SCHEMA = {
  type       : 'object',
  properties : {
    // The display name of the recipe.
    name : REQUIRED_STRING,
    // The measured ingredients for how to mix this recipe.
    ingredients : {
      type       : 'array',
      required   : true,
      items      : {
        properties : {
          tag               : OPTIONAL_STRING,
          displayAmount     : {
            type     : 'string',
            required : false,
            pattern  : /^[-. \/\d]+$/
          },
          displayUnit       : OPTIONAL_STRING,
          displayIngredient : REQUIRED_STRING
        }
      }
    },
    // A string of one or more lines explaining how to make the drink.
    instructions : REQUIRED_STRING,
    // A string of one or more lines with possibly interesting suggestions or historical notes.
    notes : OPTIONAL_STRING,
    // The display name for the source of this recipe.
    source : OPTIONAL_STRING,
    // The full URL to the source page for this recipe.
    url : OPTIONAL_STRING,
    // One of a few very broad ingredient categories that best describes the genre of this drink.
    base : {
      type     : [ 'array', 'string' ],
      required : true,
      conform(strOrArray) {
        if (_.isString(strOrArray)) {
          return BASE_LIQUORS.includes(strOrArray);
        } else if (_.isArray(strOrArray)) {
          return _.all(strOrArray, base => BASE_LIQUORS.includes(base));
        } else {
          return false;
        }
      }
    }
  }
};

const INGREDIENT_GROUP_SCHEMA = {
  type       : 'object',
  properties : {
    type    : REQUIRED_STRING,
    display : REQUIRED_STRING
  }
};

const loadRecipeFile = _.memoize(function(filename) {
  log.debug(`loading recipes from ${filename}`);
  const recipes = yaml.safeLoad(fs.readFileSync(`${__dirname}/data/${filename}.yaml`));
  log.debug(`loaded ${recipes.length} recipe(s) from ${filename}`);

  const unassignedBases = _.where(recipes, { base : definitions.UNASSIGNED_BASE_LIQUOR });
  if (unassignedBases.length) {
    log.warn(`${unassignedBases.length} recipe(s) in ${filename} have an unassigned base liquor: ${_.pluck(unassignedBases, 'name').join(', ')}`);
  }

  revalidatorUtils.validateOrThrow(recipes, {
    type  : 'array',
    items : RECIPE_SCHEMA
  });

  return _.map(recipes, normalization.normalizeRecipe);
});

const loadIngredientGroups = _.once(function() {
  log.debug("loading ingredient grouping");
  const groups = yaml.safeLoad(fs.readFileSync(`${__dirname}/data/groups.yaml`));
  log.debug(`loaded ${groups.length} groups`);

  revalidatorUtils.validateOrThrow(groups, {
    type  : 'array',
    items : INGREDIENT_GROUP_SCHEMA
  });

  return groups;
});

const loadIngredients = _.once(function() {
  log.debug("loading ingredients");
  const ingredients = yaml.safeLoad(fs.readFileSync(`${__dirname}/data/ingredients.yaml`));
  log.debug(`loaded ${ingredients.length} ingredients`);

  revalidatorUtils.validateOrThrow(ingredients, {
    type  : 'array',
    items : INGREDIENT_SCHEMA
  });

  return _.map(ingredients, normalization.normalizeIngredient);
});


module.exports = {
  loadRecipeFile,
  loadIngredientGroups,
  loadIngredients
};
