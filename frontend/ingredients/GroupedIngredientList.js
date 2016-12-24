_               = require 'lodash'
React           = require 'react'
classnames      = require 'classnames'
PureRenderMixin = require 'react-addons-pure-render-mixin'

List = require '../components/List'

stylingConstants = require '../stylingConstants'

IngredientGroupHeader = React.createClass {
  displayName : 'IngredientGroupHeader'

  propTypes :
    title         : React.PropTypes.string.isRequired
    selectedCount : React.PropTypes.number.isRequired
    onToggle      : React.PropTypes.func

  mixins : [ PureRenderMixin ]

  render : ->
    React.createElement(List.Header, {"onTouchTap": (@props.onToggle)},
      React.createElement("span", {"className": 'text'}, (@props.title)),
      (if @props.selectedCount > 0 then React.createElement("span", {"className": 'count'}, (@props.selectedCount)))
    )
}

IngredientItemGroup = React.createClass {
  displayName : 'IngredientItemGroup'

  propTypes :
    title      : React.PropTypes.string.isRequired
    isExpanded : React.PropTypes.bool

  mixins : [ PureRenderMixin ]

  getDefaultProps : -> {
    isExpanded : true
  }

  render : ->
    groupSize = React.Children.count @props.children
    if @props.isExpanded
      style = {
        height : groupSize * stylingConstants.INGREDIENTS_LIST_ITEM_HEIGHT + stylingConstants.INGREDIENTS_LIST_GROUP_HEIGHT_OFFSET
      }

    React.createElement(List.ItemGroup, {"className": (classnames { 'collapsed' : not @props.isExpanded }), "style": (style)},
      (@props.children)
    )
}

IngredientListItem = React.createClass {
  displayName : 'IngredientListItem'

  propTypes :
    isSelected : React.PropTypes.bool.isRequired
    ingredient : React.PropTypes.object.isRequired
    toggleTag  : React.PropTypes.func.isRequired

  mixins : [ PureRenderMixin ]

  render : ->
    if @props.isSelected
      className = 'is-selected'

    React.createElement(List.Item, {"className": (className), "onTouchTap": (@_toggleIngredient)},
      React.createElement("div", {"className": 'name'}, (@props.ingredient.display)),
      React.createElement("i", {"className": 'fa fa-check-circle has-ingredient-icon'})
    )

  _toggleIngredient : ->
    @props.toggleTag @props.ingredient.tag
}

GroupedIngredientList = React.createClass {
  displayName : 'GroupedIngredientList'

  propTypes :
    groupedIngredients            : React.PropTypes.array
    initialSelectedIngredientTags : React.PropTypes.object
    onSelectionChange             : React.PropTypes.func

  mixins : [ PureRenderMixin ]

  getInitialState : -> {
    expandedGroupName          : null
    selectedIngredientTags : _.clone @props.initialSelectedIngredientTags
  }

  render : ->
    ingredientCount = _.chain @props.groupedIngredients
      .pluck 'ingredients'
      .pluck 'length'
      .reduce ((sum, n) -> sum + n), 0
      .value()

    _makeListItem = (i) =>
      return React.createElement(IngredientListItem, { \
        "ingredient": (i),  \
        "isSelected": (@state.selectedIngredientTags[i.tag]?),  \
        "toggleTag": (@_toggleIngredient),  \
        "key": (i.tag)
      })

    if ingredientCount == 0
      listNodes = []
    else if ingredientCount < 10
      ingredients = _.chain @props.groupedIngredients
        .pluck 'ingredients'
        .flatten()
        .sortBy 'displayName'
        .value()

      selectedCount = _.filter(ingredients, (i) => @state.selectedIngredientTags[i.tag]?).length

      header = React.createElement(IngredientGroupHeader, { \
        "title": "All Results (#{ingredientCount})",  \
        "selectedCount": (selectedCount),  \
        "key": 'header-all-results'
      })

      listNodes = [
        header
        _.map ingredients, _makeListItem
      ]

    else
      listNodes = []
      for { name, ingredients } in @props.groupedIngredients
        ingredientNodes = []
        selectedCount = 0
        for i in ingredients
          ingredientNodes.push _makeListItem(i)
          if @state.selectedIngredientTags[i.tag]?
            selectedCount += 1
        listNodes.push [
          React.createElement(IngredientGroupHeader, { \
            "title": (name),  \
            "selectedCount": (selectedCount),  \
            "onToggle": (_.partial @_toggleGroup, name),  \
            "key": ('header-' + name)
          })
          React.createElement(IngredientItemGroup, { \
            "title": (name),  \
            "isExpanded": (@state.expandedGroupName == name),  \
            "key": ('group-' + name)
          },
            (ingredientNodes)
          )
        ]

    React.createElement(List, { \
      "className": (classnames List.ClassNames.HEADERED, List.ClassNames.COLLAPSIBLE, 'grouped-ingredient-list'),  \
      "emptyText": 'Nothing matched your search.'
    },
      (listNodes)
    )

  getSelectedTags : ->
    return @state.selectedIngredientTags

  _toggleGroup : (expandedGroupName) ->
    if @state.expandedGroupName == expandedGroupName
      @setState { expandedGroupName : null }
    else
      @setState { expandedGroupName }

  _toggleIngredient : (tag) ->
    # It is VERY IMPORTANT that these create a new instance: this is how PureRenderMixin guarantees correctness.
    if @state.selectedIngredientTags[tag]?
      selectedIngredientTags = _.omit @state.selectedIngredientTags, tag
    else
      selectedIngredientTags = _.clone @state.selectedIngredientTags
      selectedIngredientTags[tag] = true
    @setState { selectedIngredientTags }
    @props.onSelectionChange?(selectedIngredientTags)
}

module.exports = GroupedIngredientList
