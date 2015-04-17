_   = require 'lodash'
md5 = require 'md5'

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
  r.recipeId ?= md5 JSON.stringify(r)
  return r

module.exports = { normalizeIngredient, normalizeRecipe }
