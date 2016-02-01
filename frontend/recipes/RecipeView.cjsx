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
    recipe           : React.PropTypes.shape({
      name         : React.PropTypes.string.isRequired
      ingredients  : React.PropTypes.arrayOf(React.PropTypes.object).isRequired
      instructions : React.PropTypes.string
      notes        : React.PropTypes.string
      source       : React.PropTypes.string
      url          : React.PropTypes.string
      recipeId     : React.PropTypes.string
    }).isRequired
    ingredientSplits : React.PropTypes.object
    ingredientsByTag : React.PropTypes.object
    onClose          : React.PropTypes.func
    onFavorite       : React.PropTypes.func
    onEdit           : React.PropTypes.func
    isFavorited      : React.PropTypes.bool
    isShareable      : React.PropTypes.bool
    showId           : React.PropTypes.bool
    className        : React.PropTypes.string

  getDefaultProps : ->
    return {
      isShareable : false
      showId      : false
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

    if @props.recipe.instructions
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

    footerButtons = []

    if @props.onEdit
      footerButtons.push <IconButton
        key='edit'
        icon='fa-pencil-square-o'
        text='Edit'
        onTouchTap={@_edit}
      />
    if @props.isShareable
      footerButtons.push <IconButton
        key='share'
        icon='fa-share-square-o'
        text='Share'
        onTouchTap={@_share}
      />
    if @props.onFavorite
      footerButtons.push <IconButton
        key='favorite'
        icon={classnames { 'fa-star' : @props.isFavorited, 'fa-star-o' : not @props.isFavorited }}
        text='Favorite'
        onTouchTap={@_favorite}
      />

    if @props.showId
      recipeId = <div className='recipe-id'>
        <span className='explanation'>paste this ID in your spiritgui.de to save it</span>
        <span className='id'>{@props.recipe.recipeId}</span>
      </div>

    <div className={classnames 'recipe-view fixed-header-footer', @props.className}>
      {header}
      <div className='recipe-description fixed-content-pane'>
        <div className='recipe-ingredients'>
          {ingredientNodes}
        </div>
        {recipeInstructions}
        {recipeNotes}
        {recipeUrl}
        {recipeId}
      </div>
      {if footerButtons.length then <div className='fixed-footer'>{footerButtons}</div>}
    </div>

  _edit : ->
    @props.onEdit @props.recipe

  _share : ->
    window.open "sms:&body=#{@props.recipe.name} #{definitions.BASE_URL}/recipe/#{@props.recipe.recipeId}"

  _favorite : ->
    @props.onFavorite @props.recipe, not @props.isFavorited

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
