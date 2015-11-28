_               = require 'lodash'
React           = require 'react'
classnames      = require 'classnames'
PureRenderMixin = require 'react-addons-pure-render-mixin'

definitions = require '../../shared/definitions'

ReduxMixin = require '../mixins/ReduxMixin'

TitleBar = require '../components/TitleBar'
Swipable = require '../components/Swipable'

store = require '../store'

BASE_LIQUORS = [ definitions.ANY_BASE_LIQUOR ].concat definitions.BASE_LIQUORS

RecipeListHeader = React.createClass {
  displayName : 'RecipeListHeader'

  mixins : [
    ReduxMixin {
      filters : [ 'baseLiquorFilter', 'selectedRecipeList' ]
    }
    PureRenderMixin
  ]

  render : ->
    initialBaseLiquorIndex = _.indexOf BASE_LIQUORS, @state.baseLiquorFilter
    if initialBaseLiquorIndex == -1
      initialBaseLiquorIndex = 0

    <div className='recipe-list-header fixed-header'>
      <TitleBar
        leftIcon='fa-bars'
        leftIconOnTouchTap={@_showSidebar}
        rightIcon='fa-plus'
        rightIconOnTouchTap={@_newRecipe}
        className='recipe-list-header'
        onTouchTap={@_showListSelector}
      >
        {definitions.RECIPE_LIST_NAMES[@state.selectedRecipeList]}
        <i className='fa fa-chevron-down'/>
      </TitleBar>
      <Swipable
        className='base-liquor-container'
        initialIndex={initialBaseLiquorIndex}
        onSlideChange={@_onBaseLiquorChange}
        friction=0.7
      >
        {for base in BASE_LIQUORS
          <div
            className={classnames 'base-liquor-option', { 'selected' : base == @state.baseLiquorFilter }}
            key={base}
          >
            {base}
          </div>}
      </Swipable>
    </div>

  _onBaseLiquorChange : (index) ->
    store.dispatch {
      type   : 'set-base-liquor-filter'
      filter : BASE_LIQUORS[index]
    }

  _showSidebar : ->
    store.dispatch {
      type : 'show-sidebar'
    }

  _showListSelector : ->

  _newRecipe : ->
    store.dispatch {
      type : 'show-recipe-editor'
    }
}

module.exports = RecipeListHeader
