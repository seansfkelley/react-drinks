_ = require 'lodash'

module.exports = require('./makeReducer') _.extend({
  recipeViewingIndex : null
}, require('../persistence').load().ui), {
  'set-recipe-viewing-index' : (state, { index }) ->
    return _.defaults { recipeViewingIndex : index }, state
}
