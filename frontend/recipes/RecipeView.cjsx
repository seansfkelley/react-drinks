# @cjsx React.DOM

_     = require 'lodash'
md5   = require 'MD5'
React = require 'react'

AppDispatcher = require '../AppDispatcher'

utils = require '../utils'

SectionHeader = React.createClass {
  render : ->
    <div className='recipe-section-header'>{@props.text}</div>
}

# TODO: Factor this out into a MeasuredIngredientView that is easily stylable?
IngredientView = React.createClass {
  render : ->
    amount = utils.fractionify(@props.measuredIngredient.displayAmount ? '')
    unit = @props.measuredIngredient.displayUnit ? ''
    # The space is necessary to space out the spans from each other. Newlines are insufficient.
    <div className='measured-ingredient'>
      <span className='measure'>
        <span className='amount'>{amount}</span>
        {' '}
        <span className='unit'>{unit}</span>
      </span>
      <span className='ingredient'>{@props.measuredIngredient.displayIngredient}</span>
    </div>
}

IngredientCategory =
  MISSING    : 'missing'
  SUBSTITUTE : 'substitute'
  AVAILABLE  : 'available'

HUMAN_READABLE_CATEGORY_TITLE =
  missing    : 'You\'re Missing'
  substitute : 'You Can Substitute'
  available  : 'You Have'

RecipeView = React.createClass {
  render : ->
    # TODO: We're reusing this view for both types of recipes; seems bad.
    if @props.recipe.missing? and (@props.recipe.missing.length > 0 or @props.recipe.substitute.length > 0)
      ingredientNodes = _.chain IngredientCategory
        .invert()
        .mapValues (_, key) => @props.recipe[key]
        # TODO: The order these sections end up in is arbitrary; we should enforce it.
        .map (measuredIngredients, category) =>
          if measuredIngredients.length == 0
            return []
          else
            return [
              <SectionHeader text={HUMAN_READABLE_CATEGORY_TITLE[category]} key={'header-' + category}/>
              _.map measuredIngredients, (i) -> <IngredientView measuredIngredient={i} key={i.tag ? i.displayIngredient}/>
            ]
        .flatten()
        .value()
    else
      ingredientNodes = [
        <SectionHeader text='Ingredients' key={'header-' + IngredientCategory.AVAILABLE}/>
      ].concat _.map @props.recipe.ingredients, (i) ->
        <IngredientView category={IngredientCategory.AVAILABLE} measuredIngredient={i} key={i.tag ? i.displayIngredient}/>

    if @props.recipe.notes?
      recipeNotes =
        <div className='recipe-notes'>
          <SectionHeader text='Notes'/>
          <div className='text'>
            {@props.recipe.notes}
          </div>
        </div>

    instructionLines = _.map @props.recipe.instructions.split('\n'), (l, i) ->
      # The only reason I'm bothering to do this is in the interest of no warnings. I think React
      # only warns you of each error once, and I want to ensure this one doesn't crop up somewhere
      # more damaging.
      return <div className='text-line' key={md5(l)}>{l}</div>
    recipeInstructions =
      <div className='recipe-instructions'>
        <SectionHeader text='Instructions'/>
        <div className='text'>{instructionLines}</div>
      </div>

    <div className='recipe-view'>
      <div className='recipe-title fixed-header-bar'>
        {@props.recipe.name}
      </div>
      <div className='recipe-description fixed-content-pane'>
        <div className='recipe-ingredients'>
          {ingredientNodes}
        </div>
        {recipeInstructions}
        {recipeNotes}
      </div>
      <div className='recipe-controls fixed-footer-bar'>
        <div className='save-to-button' onTouchTap={@_saveTo}>
          <i className='fa fa-list-ul'/>
          <span>Save To</span>
        </div>
        <div className='close-button' onTouchTap={@_hideRecipe}>
          <span>Close</span>
          <i className='fa fa-times'/>
        </div>
      </div>
    </div>

  _saveTo : ->
    console.log 'save to'

  _hideRecipe : ->
    AppDispatcher.dispatch {
      type : 'hide-modal'
    }
}

module.exports = RecipeView