_     = require 'lodash'
React = require 'react/addons'
{ PureRenderMixin } = React.addons

FluxMixin = require './mixins/FluxMixin'

List              = require './components/List'
TitleBar          = require './components/TitleBar'
FixedHeaderFooter = require './components/FixedHeaderFooter'

# TODO:
#  - Factor out:
#    - Mixability toggle
#    - Ingredient list item result
#  - Plug them into the explanation page
#  - Make a mention of the the ingredients button and add-recipe button
#  - Should the explanation page be split in two?
#  - Add progress indicator dots at the bottom?
#  - Refactor a bunch of this paging/navigation stuff so there's less repetition

MeasuredIngredient = require './recipes/MeasuredIngredient'
MixabilityToggle = React.createClass {render : -> <div/>}

AppDispatcher       = require './AppDispatcher'
{ IngredientStore } = require './stores'

isMobileSafari = ->
  return window.navigator.userAgent.indexOf('iPhone') != -1 and window.navigator.userAgent.indexOf('CriOS') == -1

isWebClip = ->
  return !!window.navigator.standalone

FtuePage =
  WEB_CLIP    : 'webclip'
  EXPLANATION : 'explanation'
  INGREDIENTS : 'ingredients'


WebClipPage = React.createClass {
  displayName : 'WebClipPage'

  mixins : [ PureRenderMixin ]

  propTypes :
    onComplete : React.PropTypes.func.isRequired

  getInitialState : -> {
    isMobileSafari : isMobileSafari()
  }

  render : ->
    if @state.isMobileSafari
      text = <p className='explanation'>
        If you want quicker access, you can tap <img src='/img/ios-export.png'/> at the bottom of the screen to save this to the home screen.
      </p>
    else
      text = <p className='explanation'>
        You can save this to your home screen through Safari for quicker access.
        In Safari, tap <img src='/img/ios-export.png'/> at the bottom of the screen, then save to home screen.
      </p>

    <FixedHeaderFooter
      className='ftue-page web-clip-page'
      header={<TitleBar>Spirit Guide</TitleBar>}
      footer={<TitleBar onTouchTap={@props.onComplete}>Skip</TitleBar>}
    >
      <h3 className='intro'>Hey there first-timer!</h3>
      {text}
    </FixedHeaderFooter>
}


ExplanationPage = React.createClass {
  displayName : 'ExplanationPage'

  mixins : [ PureRenderMixin ]

  propTypes :
    onComplete : React.PropTypes.func.isRequired

  render : ->
    <FixedHeaderFooter
      className='ftue-page explanation-page'
      header={<TitleBar>Spirit Guide</TitleBar>}
      footer={<TitleBar onTouchTap={@props.onComplete}>Continue</TitleBar>}
    >
      <h3>Welcome!</h3>

      <p>
        Spirit Guide is an app that will tell you what you can make based on what's in your bar.
        It also understands similar ingredients, so if there's a drink with rye but you've only got bourbon:
      </p>

      <MeasuredIngredient
        displayAmount='1'
        displayUnit='oz'
        displayIngredient='rye whiskey'
        displaySubstitutes={[ 'bourbon' ]}
        isSubstituted=true
      />

      <p>
        Have you ever been suspicious that recipe-finding apps are being too strict? If you want, Spirit Guide
        will also find recipes that you can nearly make, in case there's drinks that are only a corner store
        trip away. Try toggling these:
      </p>

      <MixabilityToggle/>

      <p>
        And you'll see more or fewer recipes:
      </p>

      <List/>
    </FixedHeaderFooter>
}


# This is kind of a clone of the default ingredient selection view.
IngredientsPage = React.createClass {
  displayName : 'IngredientsPage'

  mixins : [ PureRenderMixin ]

  propTypes :
    alphabeticalIngredients       : React.PropTypes.array.isRequired
    initialSelectedIngredientTags : React.PropTypes.object.isRequired
    onComplete                    : React.PropTypes.func.isRequired

  getInitialState : -> {
    selectedIngredientTags : _.clone @props.initialSelectedIngredientTags
  }

  render : ->
    header = <div>
      <TitleBar>Spirit Guide</TitleBar>
      <p className='sub-header'>
        To get things started, select all the ingredients you have in your bar at the moment:
      </p>
    </div>

    <FixedHeaderFooter
      className='ftue-page ingredients-page'
      header={header}
      footer={<TitleBar onTouchTap={@_finish}>Finish</TitleBar>}
    >
      <List>
        {for ingredient in @props.alphabeticalIngredients
          <List.Item key={ingredient.tag} onTouchTap={@_ingredientSelector ingredient.tag}>
            <span className='name'>{ingredient.display}</span>
            {if @state.selectedIngredientTags[ingredient.tag]
              <i className='fa fa-check-circle'/>}
          </List.Item>}
      </List>
    </FixedHeaderFooter>

  _ingredientSelector : (tag) ->
    return =>
      # It is VERY IMPORTANT that these create a new instance: this is how PureRenderMixin guarantees correctness.
      if @state.selectedIngredientTags[tag]?
        selectedIngredientTags = _.omit @state.selectedIngredientTags, tag
      else
        selectedIngredientTags = _.clone @state.selectedIngredientTags
        selectedIngredientTags[tag] = true
      @setState { selectedIngredientTags }

  _finish : ->
    AppDispatcher.dispatch {
      type                   : 'set-selected-ingredient-tags'
      selectedIngredientTags : @state.selectedIngredientTags
    }
    @props.onComplete()
}


FtueView = React.createClass {
  displayName : 'FtueView'

  mixins : [ PureRenderMixin ]

  propTypes :
    alphabeticalIngredients       : React.PropTypes.array.isRequired
    initialSelectedIngredientTags : React.PropTypes.object.isRequired
    onComplete                    : React.PropTypes.func.isRequired

  getInitialState : -> {
    isWebClip   : isWebClip()
    currentPage : if isWebClip() then FtuePage.EXPLANATION else FtuePage.WEB_CLIP
  }

  render : ->
    return switch @state.currentPage
      when FtuePage.WEB_CLIP
        <WebClipPage onComplete={@_makePageSwitcher(FtuePage.EXPLANATION)}/>
      when FtuePage.EXPLANATION
        <ExplanationPage onComplete={@_makePageSwitcher(FtuePage.INGREDIENTS)}/>
      when FtuePage.INGREDIENTS
        <IngredientsPage
          alphabeticalIngredients={@props.alphabeticalIngredients}
          initialSelectedIngredientTags={@props.initialSelectedIngredientTags}
          onComplete={@props.onComplete}
        />

  _makePageSwitcher : (targetPage) ->
    return =>
      @setState { currentPage : targetPage }
}

module.exports = FtueView
