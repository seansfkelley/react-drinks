_               = require 'lodash'
React           = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'
classnames      = require 'classnames'

utils       = require '../utils'
definitions = require '../../shared/definitions'

ReduxMixin = require '../mixins/ReduxMixin'

TitleBar = require '../components/TitleBar'

MeasuredIngredient = require './MeasuredIngredient'

IS_IPHONE_IOS_8 = window.navigator.userAgent.indexOf('iPhone OS 8') != -1

IngredientCategory = {
  MISSING    : 'missing'
  SUBSTITUTE : 'substitute'
  AVAILABLE  : 'available'
}

IconButton = ({ icon, text, onTouchTap }) ->
  <div className='icon-button' onTouchTap={onTouchTap}>
    <i className={classnames 'fa', icon}/>
    <div className='label'>{text}</div>
  </div>

IconButton.propTypes = {
  icon       : React.PropTypes.string
  text       : React.PropTypes.string
  onTouchTap : React.PropTypes.func
}

RecipeView = React.createClass {
  displayName : 'RecipeView'

  mixins : [ PureRenderMixin ]

  propTypes :
    recipe           : React.PropTypes.object.isRequired
    ingredientSplits : React.PropTypes.object
    ingredientsByTag : React.PropTypes.object
    onClose          : React.PropTypes.func
    shareable        : React.PropTypes.bool

  getDefaultProps : ->
    return {
      shareable : false
    }

  render : ->
    if @props.ingredientSplits?
      ingredientNodes = _.chain IngredientCategory
        .invert()
        .mapValues (_, key) => @props.ingredientSplits[key]
        # TODO: The order these sections end up in is arbitrary; we should enforce it.
        .map @_renderCategory
        .flatten()
        .value()
    else
      ingredientNodes = _.map @props.recipe.ingredients, (i) ->
        # This fucked-up key is because sometimes, the same tag will appear twice (e.g. Penicillin's two scotches).
        <MeasuredIngredient {...i} key={"#{i.tag} #{i.displayIngredient}"}/>

    if @props.recipe.notes?
      recipeNotes =
        <div className='recipe-notes'>
          <div className='text'>
            {utils.fractionify @props.recipe.notes}
          </div>
        </div>

    if @props.recipe.source? and @props.recipe.url?
      recipeUrl = <a className='recipe-url' href={@props.recipe.url} target='_blank'>
        <span className='lead-in'>source:</span>
        {@props.recipe.source}
        <i className='fa fa-external-link'/>
      </a>

    instructionLines = _.chain @props.recipe.instructions.split('\n')
      .compact()
      .map (l, i) -> <li className='text-line' key={i}>{utils.fractionify l}</li>
      .value()
    recipeInstructions = <ol className='recipe-instructions'>{instructionLines}</ol>

    if @props.onClose?
      header = <TitleBar className='fixed-header' rightIcon='fa-times' rightIconOnTouchTap={@props.onClose}>
        {@props.recipe.name}
      </TitleBar>
    else
      header = <TitleBar className='fixed-header'>{@props.recipe.name}</TitleBar>

    <div className='recipe-view fixed-header-footer'>
      {header}
      <div className='recipe-description fixed-content-pane'>
        <div className='recipe-ingredients'>
          {ingredientNodes}
        </div>
        {recipeInstructions}
        {recipeNotes}
        {recipeUrl}
      </div>
      <div className='fixed-footer'>
        <IconButton icon='fa-share-square-o' text='Share' onTouchTap={@_share}/>
        <IconButton icon='fa-star' text='Favorite' onTouchTap={@_favorite}/>
      </div>
    </div>

  _share : ->
    window.open "sms:&body=#{@props.recipe.name} #{definitions.BASE_URL}/recipe/#{@props.recipe.recipeId}"

  _favorite : ->
    console.log 'favorited'

  _renderCategory : (measuredIngredients, category) ->
    if measuredIngredients.length == 0
      return []
    else
      if category == IngredientCategory.SUBSTITUTE
        measuredIngredients = _.map measuredIngredients, (i) ->
          return _.defaults {
            isSubstituted      : true
            displaySubstitutes : i.have
          }, i.need
      else if category == IngredientCategory.MISSING
        measuredIngredients = _.map measuredIngredients, (i) =>
          return _.defaults {
            isMissing  : true
            difficulty : @props.ingredientsByTag[i.tag].difficulty
          }, i

      return _.map measuredIngredients, (i) -> <MeasuredIngredient {...i} key={"#{i.tag} #{i.displayIngredient}"}/>
}

module.exports = RecipeView
