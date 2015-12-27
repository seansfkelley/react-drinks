_     = require 'lodash'
React = require 'react'

definitions = require '../../../shared/definitions'

TitleBar = require '../../components/TitleBar'

RecipeView = require '../../recipes/RecipeView'

# TODO: Hacky as fuuuuuck.
# I think I want to persist custom recipe IDs to the server as a lightweight "account", in which
# case this should be rewritten to do that.
hackyGetLocalStorageData = ->
  return JSON.parse(localStorage['drinks-app-persistence'] ? '{}')

hackyCheckIfIsInLibrary = (recipeId) ->
  return recipeId in _.get(hackyGetLocalStorageData(), 'data.recipes.customRecipeIds', [])

hackyAddToLibraryAndPersist = (recipeId) ->
  persistedData = hackyGetLocalStorageData()
  customRecipeIds = _.get persistedData, 'data.recipes.customRecipeIds', []
  if recipeId not in customRecipeIds
    customRecipeIds.push recipeId
    localStorage['drinks-app-persistence'] = JSON.stringify persistedData

StandaloneRecipeView = React.createClass {
  displayName : 'StandaloneRecipeView'

  propTypes :
    recipe : React.PropTypes.object.isRequired

  getInitialState : ->
    return {
      isInLibrary : hackyCheckIfIsInLibrary @props.recipe.recipeId
    }

  render : ->
    <div className='standalone-recipe'>
      <a className='homepage-link' href={definitions.BASE_URL} target='_blank'>
        <TitleBar>
          Spirit Guide
          <i className='fa fa-chevron-right'/>
        </TitleBar>
      </a>
      <RecipeView
        recipe={@props.recipe}
        isCustomAdded={@state.isInLibrary}
        onCustomAdd={if @props.recipe.isCustom then @_customAdd}
      />
    </div>

  _customAdd : (recipeId) ->
    hackyAddToLibraryAndPersist recipeId
    @setState { isInLibrary : true }
}

module.exports = StandaloneRecipeView
