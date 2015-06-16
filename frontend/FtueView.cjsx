_     = require 'lodash'
React = require 'react/addons'
{ PureRenderMixin } = React.addons

FluxMixin = require './mixins/FluxMixin'

List              = require './components/List'
TitleBar          = require './components/TitleBar'
FixedHeaderFooter = require './components/FixedHeaderFooter'

# TODO:
#  - Make a mention of the the ingredients button and add-recipe button
#  - Should the explanation page be split in two?
#  - Add progress indicator dots at the bottom?
#  - Refactor a bunch of this paging/navigation stuff so there's less repetition

MeasuredIngredient = require './recipes/MeasuredIngredient'
MixabilityToggle   = require './recipes/MixabilityToggle'
RecipeListItem     = require './recipes/RecipeListItem'

AppDispatcher       = require './AppDispatcher'
{ IngredientStore } = require './stores'

isMobileSafari = ->
  return window.navigator.userAgent.indexOf('iPhone') != -1 and window.navigator.userAgent.indexOf('CriOS') == -1

isWebClip = ->
  return !!window.navigator.standalone

FtuePage =
  WELCOME      : 'welcome'
  SUBSTITUTION : 'substitution'
  MIXABILITY   : 'mixability'
  INGREDIENTS  : 'ingredients'


WelcomePage = React.createClass {
  displayName : 'WelcomePage'

  mixins : [ PureRenderMixin ]

  propTypes :
    onComplete : React.PropTypes.func.isRequired

  getInitialState : -> {
    isMobileSafari : isMobileSafari()
    isWebClip      : isWebClip()
  }

  render : ->
    if @state.isMobileSafari
      webClipNotification = [
        <h3>Protip!</h3>
        <p className='explanation'>
          If you want quicker access, you can tap <img src='/img/ios-export.png'/> at the bottom of the screen to save this to the home screen.
        </p>
      ]
    else if not @state.isWebClip
      webClipNotification = [
        <h3>Protip:</h3>
        <p className='explanation'>
          You can save this to your home screen through Safari for quicker access.
          In Safari, tap <img src='/img/ios-export.png'/> at the bottom of the screen, then save to home screen.
        </p>
      ]

    <FixedHeaderFooter
      className='ftue-page web-clip-page'
      header={<TitleBar>Spirit Guide</TitleBar>}
      footer={<TitleBar onTouchTap={@props.onComplete}>Continue</TitleBar>}
    >
      <h3>Welcome!</h3>
      <p>
        Spirit Guide is an app that will tell you what cocktails you can make based on what's in your liquor cabinet.
      </p>
      {webClipNotification}
    </FixedHeaderFooter>
}


DUMMY_LIST_ITEMS = [
  recipeName : 'Aviation'
  mixability : 2
,
  recipeName : 'Gin & Tonic'
  mixability : 0
,
  recipeName : 'Margarita'
  mixability : 3
,
  recipeName : 'Whiskey Sour'
  mixability : 1
]

_filterDummyListItems = (mixabilityToggles) ->
  allow = []
  if mixabilityToggles.mixable
    allow.push 0
  if mixabilityToggles.nearMixable
    allow.push 1
  if mixabilityToggles.notReallyMixable
    allow.push [2, 3]...
  return _.filter DUMMY_LIST_ITEMS, ({ mixability }) -> mixability in allow

SubstitionPage = React.createClass {
  displayName : 'SubstitionPage'

  mixins : [ PureRenderMixin ]

  propTypes :
    onComplete : React.PropTypes.func.isRequired

  render : ->
    <FixedHeaderFooter
      className='ftue-page explanation-page'
      header={<TitleBar>Spirit Guide</TitleBar>}
      footer={<TitleBar onTouchTap={@props.onComplete}>Continue</TitleBar>}
    >
      <h3>Substitutions</h3>

      <p>
        If an ingredient can be substituted with something else you have, recipes with that ingredient
        will still show up.
      </p>
      <p>
        Substitutes look like this:
      </p>

      <MeasuredIngredient
        displayAmount='1'
        displayUnit='oz'
        displayIngredient='rye whiskey'
        displaySubstitutes={[ 'bourbon' ]}
        isSubstituted=true
      />
    </FixedHeaderFooter>
}

MixabilityPage = React.createClass {
  displayName : 'MixabilityPage'

  mixins : [ PureRenderMixin ]

  propTypes :
    onComplete : React.PropTypes.func.isRequired

  getInitialState : -> {
    mixabilityToggles :
      mixable          : true
      nearMixable      : true
      notReallyMixable : true
  }

  render : ->
    dummyRecipeNodes = _.map _filterDummyListItems(@state.mixabilityToggles), (props) ->
      return <RecipeListItem key={props.recipeName} {...props}/>

     <FixedHeaderFooter
       className='ftue-page explanation-page'
       header={<TitleBar>Spirit Guide</TitleBar>}
       footer={<TitleBar onTouchTap={@props.onComplete}>Continue</TitleBar>}
     >
      <h3>Mixability</h3>
      <p>
        You can change how lenient the searching is, in case there are drinks that are just missing something
        from the corner store.
      </p>
      <p>
        Try toggling these:
      </p>

      <MixabilityToggle
        mixabilityToggles={@state.mixabilityToggles}
        onToggle={@_onMixabilityToggle}
      />

      <p>
        And you'll see more or fewer recipes:
      </p>

      <List>
        {dummyRecipeNodes}
      </List>
    </FixedHeaderFooter>

  _onMixabilityToggle : (setting) ->
    @state.mixabilityToggles[setting] = not @state.mixabilityToggles[setting]
    @setState { mixabilityToggles : _.clone @state.mixabilityToggles }
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
    currentPage : FtuePage.WELCOME
  }

  render : ->
    return switch @state.currentPage
      when FtuePage.WELCOME
        <WelcomePage onComplete={@_makePageSwitcher(FtuePage.SUBSTITUTION)}/>
      when FtuePage.SUBSTITUTION
        <SubstitionPage onComplete={@_makePageSwitcher(FtuePage.MIXABILITY)}/>
      when FtuePage.MIXABILITY
        <MixabilityPage onComplete={@_makePageSwitcher(FtuePage.INGREDIENTS)}/>
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
