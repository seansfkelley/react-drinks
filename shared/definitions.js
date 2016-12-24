const _      = require('lodash');
const assert = require('./tinyassert');

module.exports = {
  BASE_URL               : 'http://spiritgui.de',
  BASE_LIQUORS           : [ 'gin', 'vodka', 'whiskey', 'rum', 'brandy', 'tequila', 'wine', 'liqueur' ],
  ANY_BASE_LIQUOR        : 'any',
  UNASSIGNED_BASE_LIQUOR : 'UNASSIGNED',
  RECIPE_LIST_TYPES      : [ 'all', 'mixable', 'favorites', 'custom' ],
  RECIPE_LIST_NAMES      : {
    all       : 'All Drinks',
    mixable   : 'Mixable Drinks',
    favorites : 'Favorites',
    custom    : 'Custom Drinks'
  },
  BASE_TITLES_BY_TAG : {
    gin     : 'Gin',
    vodka   : 'Vodka',
    whiskey : 'Whiskey',
    rum     : 'Rum',
    brandy  : 'Brandy/Cognac',
    tequila : 'Tequila/Mezcal',
    wine    : 'Wine/Champagne',
    liqueur : 'Liqueur/Other'
  }
};

assert(_.intersection(_.keys(module.exports.BASE_TITLES_BY_TAG), module.exports.BASE_LIQUORS).length === module.exports.BASE_LIQUORS.length);
