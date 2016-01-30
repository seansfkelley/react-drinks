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
    <div className='ingredients-sidebar'>
      <SearchBar placeholder='Ingredient name...' onChange={@_onSearch}/>
      <GroupedIngredientList
        groupedIngredients={@state.filteredGroupedIngredients}
        initialSelectedIngredientTags={@state.selectedIngredientTags}
        onSelectionChange={@_onIngredientToggle}
        ref='ingredientList'
      />
    </div>

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
