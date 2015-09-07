module.exports = require('makeReducer') {
  recipeViewingIndex : null
}, {
  'set-recipe-viewing-index' : (state, { index }) ->
    return _.defaults { recipeViewingIndex : index }, state
}
