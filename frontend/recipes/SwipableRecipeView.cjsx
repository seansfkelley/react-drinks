_     = require 'lodash'
React = require 'react/addons'

Swipable = require '../components/Swipable'

RecipeView = require './RecipeView'

SwipableRecipeView = React.createClass {
  displayName : 'SwipableRecipeView'

  propTypes :
    recipes : React.PropTypes.array.isRequired
    index   : React.PropTypes.number.isRequired

  getInitialState : -> {
    visibleIndex : @props.index
  }

  render : ->
    recipePages = _.map @props.recipes, (r, i) =>
      <div className='swipable-padding-wrapper' key={r.recipeId}>
        {if Math.abs(i - @state.visibleIndex) <= 1
          <div className='swipable-position-wrapper'>
            <RecipeView recipe={r}/>
          </div>}
      </div>

    <Swipable initialIndex={@props.index} onSlideChange={@_onSlideChange}>
      {recipePages}
    </Swipable>

  _onSlideChange : (index) ->
    @setState { visibleIndex : index }
}

module.exports = SwipableRecipeView
