import * as Promise from 'bluebird';
import * as reqwest from 'reqwest';

export function saveRecipe(recipe) {
  return (dispatch, getState) => {
    dispatch({
      type: 'saving-recipe'
    });

    const recipeNoId = _.omit(recipe, 'originalRecipeId');
    return Promise.resolve(reqwest({
      url: '/recipe',
      method: 'post',
      type: 'json',
      data: recipeNoId
    })).then(function ({ ackRecipeId }) {
      dispatch({
        type: 'saved-recipe',
        recipe: _.extend({ recipeId: ackRecipeId }, recipeNoId)
      });

      if (recipe.originalRecipeId) {
        dispatch({
          type: 'rewrite-recipe-id',
          from: recipe.originalRecipeId,
          to: ackRecipeId
        });

        return dispatch({
          type: 'delete-recipe',
          recipeId: recipe.originalRecipeId
        });
      }
    });
  };
}
