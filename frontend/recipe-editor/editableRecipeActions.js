Promise = require 'bluebird'
reqwest = require 'reqwest'

saveRecipe = (recipe) ->
  return (dispatch, getState) ->
    dispatch {
      type : 'saving-recipe'
    }

    recipeNoId = _.omit recipe, 'originalRecipeId'
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

      if recipe.originalRecipeId
        dispatch {
          type : 'rewrite-recipe-id'
          from : recipe.originalRecipeId
          to   : ackRecipeId
        }

        dispatch {
          type     : 'delete-recipe'
          recipeId : recipe.originalRecipeId
        }

module.exports = {
  saveRecipe
}
