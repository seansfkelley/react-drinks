Promise = require 'bluebird'
reqwest = require 'reqwest'

saveRecipe = (recipe) ->
  return (dispatch, getState) ->
    dispatch {
      type : 'save-recipe'
      recipe
    }

    Promise.resolve reqwest({
      url    : '/recipe'
      method : 'post'
      type   : 'json'
      data   : recipe
    })
    .done ({ ackRecipeId }) ->
      dispatch {
        type : 'rewrite-recipe-id'
        from : recipe.recipeId
        to   : ackRecipeId
      }

module.exports = {
  saveRecipe
}
