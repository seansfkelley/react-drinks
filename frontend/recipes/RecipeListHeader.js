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

    React.createElement("div", {"className": 'recipe-list-header fixed-header'},
      React.createElement(TitleBar, { \
        "leftIcon": '/assets/img/ingredients.svg',  \
        "leftIconOnTouchTap": (@_showSidebar),  \
        "rightIcon": 'fa-plus',  \
        "rightIconOnTouchTap": (@_newRecipe),  \
        "className": 'recipe-list-header',  \
        "onTouchTap": (@_showListSelector)
      },
        (definitions.RECIPE_LIST_NAMES[@state.selectedRecipeList]),
        React.createElement("i", {"className": 'fa fa-chevron-down'})
      ),
      React.createElement(Swipable, { \
        "className": 'base-liquor-container',  \
        "initialIndex": (initialBaseLiquorIndex),  \
        "onSlideChange": (@_onBaseLiquorChange),  \
        "friction": 0.7
      },
        (_.map(BASE_LIQUORS, (base) =>
          React.createElement("div", { \
            "className": (classnames 'base-liquor-option', { 'selected' : base == @state.baseLiquorFilter }),  \
            "key": (base)
          },
            (base)
        )))
      )
    );

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
    store.dispatch {
      type : 'show-list-selector'
    }

  _newRecipe : ->
    store.dispatch {
      type : 'show-recipe-editor'
    }
}

module.exports = RecipeListHeader