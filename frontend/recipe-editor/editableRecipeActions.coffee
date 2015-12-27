Promise = require 'bluebird'
reqwest = require 'reqwest'

saveRecipe = (recipe) ->
  return (dispatch, getState) ->
    dispatch {
      type : 'saving-recipe'
    }

    recipeNoId = _.omit recipe, 'recipeId'
    return Promise.resolve reqwest({
      url    : '/recipe'
      method : 'post'
      type   : 'json'
      data   : recipeNoId
    })
    .then ({ ackRecipeId }) ->
      dispatch {
        type   : 'saved-recipe'
        recipe : _.extend { recipeId : ackRecipeId }, recipeNoId
      }

module.exports = {
  saveRecipe
}
