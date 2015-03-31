_        = require 'lodash'
latinize = require './latinize'

normalizeIngredient = (i) ->
  i = _.clone i
  i.tag        ?= i.display.toLowerCase()
  i.searchable ?= []
  i.searchable.push latinize(i.display).toLowerCase()
  # TODO: Add display for generic to here.
  # if i.generic and not _.contains i.searchable, i.generic
  #   i.searchable.push i.generic
  return i

normalizeRecipe = (r) ->
  r = _.clone r
  r.searchableName = latinize(r.name).toLowerCase()
  r.normalizedName = r.searchableName.replace('/ /g', '-').replace(/[^-a-z0-9]/g, '')
  return r

module.exports = { normalizeIngredient, normalizeRecipe }
