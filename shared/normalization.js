_ = require 'lodash'

assert = require './tinyassert'

normalizeIngredient = (i) ->
  assert i.display

  i = _.clone i
  i.tag        ?= i.display.toLowerCase()
  i.searchable ?= []
  i.searchable.push _.deburr(i.display).toLowerCase()
  i.searchable.push i.tag
  i.tangible ?= true
  # TODO: Add display for generic to here.
  # if i.generic and not _.contains i.searchable, i.generic
  #   i.searchable.push i.generic
  return i

normalizeRecipe = (r) ->
  assert r.name

  r = _.clone r
  r.canonicalName = _.deburr(r.name).toLowerCase()
  nameWords = r.canonicalName.split ' '
  if nameWords[0] in [ 'a', 'the' ]
    r.sortName = nameWords[1..].join ' '
  else
    r.sortName = r.canonicalName
  r.base ?= []
  return r

module.exports = { normalizeIngredient, normalizeRecipe }
