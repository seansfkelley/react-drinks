# @cjsx React.DOM

_     = require 'lodash'
md5   = require 'MD5'
React = require 'react'

AppDispatcher = require '../AppDispatcher'
FluxMixin     = require '../mixins/FluxMixin'
utils         = require '../utils'

{ UiStore } = require '../stores'

FixedHeaderFooter = require '../components/FixedHeaderFooter'
TitleBar          = require '../components/TitleBar'
ButtonBar         = require '../components/ButtonBar'

IngredientCategory =
  MISSING    : 'missing'
  SUBSTITUTE : 'substitute'
  AVAILABLE  : 'available'

HUMAN_READABLE_CATEGORY_TITLE =
  missing    : 'You\'re Missing'
  substitute : 'You Can Substitute'
  available  : 'You Have'

SectionHeader = React.createClass {
  displayName : 'SectionHeader'

  propTypes :
    text : React.PropTypes.string.isRequired

  render : ->
    <div className='recipe-section-header'>{@props.text}</div>
}

IngredientView = React.createClass {
  displayName : 'IngredientView'

  propTypes :
    displayAmount     : React.PropTypes.string
    displayUnit       : React.PropTypes.string
    displayIngredient : React.PropTypes.string.isRequired

  render : ->
    amount = utils.fractionify(@props.displayAmount ? '')
    unit = @props.displayUnit ? ''
    # The space is necessary to space out the spans from each other. Newlines are insufficient.
    <div className='measured-ingredient'>
      <span className='measure'>
        <span className='amount'>{amount}</span>
        {' '}
        <span className='unit'>{unit}</span>
      </span>
      <span className='ingredient'>{@props.displayIngredient}</span>
    </div>
}

RecipeFooter = React.createClass {
  displayName : 'RecipeFooter'

  propTypes :
    normalizedRecipeName : React.PropTypes.string.isRequired
    onClose              : React.PropTypes.func.isRequired

  mixins : [
    FluxMixin UiStore, 'favoritedRecipes'
  ]

  render : ->
    if @state.favoritedRecipes[@props.normalizedRecipeName]?
      saveIcon = 'fa-star'
    else
      saveIcon = 'fa-star-o'

    <ButtonBar className='recipe-controls'>
      <ButtonBar.Button icon={saveIcon} label='Favorite' onTouchTap={@_saveTo}/>
      <ButtonBar.Button icon='fa-times' label='Close' onTouchTap={@props.onClose}/>
    </ButtonBar>

  _saveTo : ->
    AppDispatcher.dispatch {
      type           : 'toggle-favorite-recipe'
      normalizedName : @props.normalizedRecipeName
    }
}

RecipeView = React.createClass {
  displayName : 'RecipeView'

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
              _.map measuredIngredients, (i) -> <IngredientView {...i} key={i.tag ? i.displayIngredient}/>
            ]
        .flatten()
        .value()
    else
      ingredientNodes = [
        <SectionHeader text='Ingredients' key={'header-' + IngredientCategory.AVAILABLE}/>
      ].concat _.map @props.recipe.ingredients, (i) ->
        <IngredientView {...i} key={i.tag ? i.displayIngredient}/>

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

    <FixedHeaderFooter
      className='recipe-view'
      header={<TitleBar title={@props.recipe.name}/>}
      footer={<RecipeFooter normalizedRecipeName={@props.recipe.normalizedName} onClose={@_onClose}/>}
    >
      <div className='recipe-description'>
        <div className='recipe-ingredients'>
          {ingredientNodes}
        </div>
        {recipeInstructions}
        {recipeNotes}
      </div>
    </FixedHeaderFooter>

  _onClose : ->
    AppDispatcher.dispatch {
      type : 'hide-modal'
    }
}

module.exports = RecipeView
