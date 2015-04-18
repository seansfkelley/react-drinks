_   = require 'lodash'
md5 = require 'MD5'

assert   = require './tinyassert'
latinize = require './latinize'

normalizeIngredient = (i) ->
  assert i.display

  i = _.clone i
  i.tag        ?= i.display.toLowerCase()
  i.searchable ?= []
  i.searchable.push latinize(i.display).toLowerCase()
  i.tangible ?= true
  # TODO: Add display for generic to here.
  # if i.generic and not _.contains i.searchable, i.generic
  #   i.searchable.push i.generic
  return i

normalizeRecipe = (r) ->
  assert r.name

  r = _.clone r
  r.canonicalName = latinize(r.name).toLowerCase()
  # So, we don't really care if this is a hash or not. It just needs to be sufficiently unique.
  # The reason it does this is because it avoids accidentally assigning the same ID to a default
  # recipe (which don't come with any) and a custom recipe (which should retain theirs forever).
  r.recipeId ?= md5 JSON.stringify(r)
  return r

module.exports = { normalizeIngredient, normalizeRecipe }
