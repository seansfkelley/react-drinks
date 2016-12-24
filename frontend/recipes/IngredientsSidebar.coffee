_               = require 'lodash'
React           = require 'react'
classnames      = require 'classnames'
Isvg            = require 'react-inlinesvg'
PureRenderMixin = require 'react-addons-pure-render-mixin'

ReduxMixin        = require '../mixins/ReduxMixin'
DerivedValueMixin = require '../mixins/DerivedValueMixin'

store            = require '../store'
stylingConstants = require '../stylingConstants'

SearchBar             = require '../components/SearchBar'
GroupedIngredientList = require '../ingredients/GroupedIngredientList'

IngredientsSidebar = React.createClass {
  displayName : 'IngredientsSidebar'

  propTypes :
    onClose : React.PropTypes.func.isRequired

  mixins : [
    ReduxMixin {
      filters : 'selectedIngredientTags'
    }
    DerivedValueMixin 'filteredGroupedIngredients'
    PureRenderMixin
  ]

  render : ->
    React.createElement("div", {"className": 'ingredients-sidebar'},
      React.createElement(SearchBar, {"placeholder": 'Ingredient name...', "onChange": (@_onSearch)}),
      React.createElement(GroupedIngredientList, { \
        "groupedIngredients": (@state.filteredGroupedIngredients),  \
        "initialSelectedIngredientTags": (@state.selectedIngredientTags),  \
        "onSelectionChange": (@_onIngredientToggle),  \
        "ref": 'ingredientList'
      })
    )

  _onSearch : (searchTerm) ->
    store.dispatch {
      type : 'set-ingredient-search-term'
      searchTerm
    }

  forceClose : ->
    store.dispatch {
      type : 'set-selected-ingredient-tags'
      tags : @refs.ingredientList.getSelectedTags()
    }
    @props.onClose()
}

module.exports = IngredientsSidebar
