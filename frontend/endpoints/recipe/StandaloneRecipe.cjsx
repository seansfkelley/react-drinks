React = require 'react'

definitions = require '../../../shared/definitions'

TitleBar = require '../../components/TitleBar'

RecipeView = require '../../recipes/RecipeView'

StandaloneRecipeView = React.createClass {
  displayName : 'StandaloneRecipeView'

  propTypes :
    recipe : React.PropTypes.object.isRequired

  render : ->
    <div className='standalone-recipe'>
      <a className='homepage-link' href={definitions.BASE_URL} target='_blank'>
        <TitleBar>
          Spirit Guide
          <i className='fa fa-chevron-right'/>
        </TitleBar>
      </a>
      <RecipeView recipe={@props.recipe}/>
    </div>
}

module.exports = StandaloneRecipeView
