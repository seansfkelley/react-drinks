const _ = require('lodash');

const assert = require('./tinyassert');

const normalizeIngredient = function (i) {
  assert(i.display);

  i = _.clone(i);
  if (i.tag == null) {
    i.tag = i.display.toLowerCase();
  }
  if (i.searchable == null) {
    i.searchable = [];
  }
  i.searchable.push(_.deburr(i.display).toLowerCase());
  i.searchable.push(i.tag);
  if (i.tangible == null) {
    i.tangible = true;
  }
  // TODO: Add display for generic to here.
  // if i.generic and not _.contains i.searchable, i.generic
  //   i.searchable.push i.generic
  return i;
};

const normalizeRecipe = function (r) {
  assert(r.name);

  r = _.clone(r);
  r.canonicalName = _.deburr(r.name).toLowerCase();
  const nameWords = r.canonicalName.split(' ');
  if (['a', 'the'].includes(nameWords[0])) {
    r.sortName = nameWords.slice(1).join(' ');
  } else {
    r.sortName = r.canonicalName;
  }
  if (r.base == null) {
    r.base = [];
  }
  return r;
};

module.exports = { normalizeIngredient, normalizeRecipe };

