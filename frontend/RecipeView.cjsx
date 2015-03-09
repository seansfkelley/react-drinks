# @cjsx React.DOM

_     = require 'lodash'
md5   = require 'MD5'
React = require 'react'

AppDispatcher = require './AppDispatcher'

HTML_FRACTIONS =
  '1/4' : '\u00bc'
  '1/2' : '\u00bd'
  '3/4' : '\u00be'
  '1/8' : '\u215b'
  '3/8' : '\u215c'
  '5/8' : '\u215d'
  '7/8' : '\u215e'
  '1/3' : '\u2153'
  '2/3' : '\u2154'

ALL_FRACTION_REGEX = new RegExp _.keys(HTML_FRACTIONS).join('|'), 'g'

SectionHeader = React.createClass {
  render : ->
    <div className='recipe-section-header'>{@props.text}</div>
}

IngredientView = React.createClass {
  render : ->
    amount = (@props.measuredIngredient.displayAmount ? '')
      .replace(ALL_FRACTION_REGEX, (match) -> HTML_FRACTIONS[match])
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
    if @props.recipe.missing? # TODO: We're reusing this view for both types of recipes; seems bad.
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
        <div className='save-to-button' onClick={@_saveTo}>
          <i className='fa fa-list-ul'/>
          <span>Save To</span>
        </div>
        <div className='close-button' onClick={@_hideRecipe}>
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
