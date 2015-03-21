# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FluxMixin        = require '../mixins/FluxMixin'
AppDispatcher    = require '../AppDispatcher'
stylingConstants = require '../stylingConstants'

{ IngredientStore, UiStore } = require '../stores'

List              = require '../components/List'
Header            = require '../components/Header'
FixedHeaderFooter = require '../components/FixedHeaderFooter'
HeaderWithSearch  = require '../components/HeaderWithSearch'

IngredientSelectionHeader = React.createClass {
  displayName : 'IngredientSelectionHeader'

  render : ->
    <HeaderWithSearch
      leftIcon='fa-chevron-down'
      leftIconOnTouchTap={@_hideIngredients}
      title='Ingredients'
      onSearch={@_setSearchTerm}
      placeholder='Ingredient name...'
    />

  # In the future, this should pop up a loader and then throttle the number of filters performed.
  _setSearchTerm : (searchTerm) ->
    AppDispatcher.dispatch {
      type : 'search-ingredients'
      searchTerm
    }

  _hideIngredients : ->
    AppDispatcher.dispatch {
      type : 'hide-flyup'
    }
}

IngredientGroupHeader = React.createClass {
  displayName : 'IngredientGroupHeader'

  mixins : [
    FluxMixin UiStore, 'openIngredientGroups'
  ]

  render : ->
    <List.Header onTouchTap={@_toggleGroup}>
      <span className='text'>{@props.title}</span>
      {if @props.selectedCount > 0 then <span className='count'>{@props.selectedCount}</span>}
    </List.Header>

  _toggleGroup : ->
    AppDispatcher.dispatch {
      type  : 'toggle-ingredient-group'
      group : @props.title
    }
}

IngredientItemGroup = React.createClass {
  displayName : 'IngredientItemGroup'

  mixins : [
    FluxMixin UiStore, 'openIngredientGroups'
  ]

  render : ->
    groupSize = React.Children.count @props.children
    if @_isCollapsed()
      className = 'collapsed'
    else
      style = {
        height : groupSize * stylingConstants.INGREDIENTS_LIST_ITEM_HEIGHT + stylingConstants.INGREDIENTS_LIST_GROUP_HEIGHT_OFFSET
      }

    <List.ItemGroup className={className} style={style}>
      {@props.children}
    </List.ItemGroup>

  _isCollapsed : ->
    return not @state.openIngredientGroups[@props.title]
}

IngredientListItem = React.createClass {
  displayName : 'IngredientListItem'

  mixins : [
    FluxMixin IngredientStore, 'selectedIngredientTags'
  ]

  render : ->
    if @state.selectedIngredientTags[@props.ingredient.tag]
      className = 'is-selected'

    <List.Item className={className} onTouchTap={@_toggleIngredient}>
      <div className='name'>{@props.ingredient.display}</div>
      <i className='fa fa-check-circle'/>
    </List.Item>

  _toggleIngredient : ->
    AppDispatcher.dispatch {
      type : 'toggle-ingredient'
      tag  : @props.ingredient.tag
    }
}

GroupedIngredientList = React.createClass {
  display : 'GroupedIngredientList'

  mixins : [
    FluxMixin IngredientStore, 'searchedGroupedIngredients', 'selectedIngredientTags'
  ]

  render : ->
    tagToGroupName = {}
    for { name, ingredients} in @state.searchedGroupedIngredients
      for i in ingredients
        tagToGroupName[i.tag] = name

    ingredientNodes = _.chain @state.searchedGroupedIngredients
      .map ({ ingredients }) => _.map ingredients, (i) -> <IngredientListItem ingredient={i} key={i.tag}/>
      .flatten()
      .value()

    headeredNodes = List.headerify {
      nodes             : ingredientNodes
      Header            : IngredientGroupHeader
      ItemGroup         : IngredientItemGroup
      computeHeaderData : (node, i) =>
        title         = tagToGroupName[node.props.ingredient.tag]
        selectedCount = _.chain @state.searchedGroupedIngredients
          .where { name : title }
          .value()[0]
          .ingredients
          .filter (i) => @state.selectedIngredientTags[i.tag]?
          .length
        return {
          title
          selectedCount
          key : 'header-' + title
        }
    }
    className = "#{List.ClassNames.HEADERED} #{List.ClassNames.COLLAPSIBLE} ingredient-list"

    <List className={className} emptyText='Nothing matched your search.'>
      {headeredNodes}
    </List>
}

IngredientSelectionView = React.createClass {
  displayName : 'IngredientSelectionView'

  render : ->
    <FixedHeaderFooter
      className='ingredient-selection-view'
      header={<IngredientSelectionHeader/>}
    >
      <GroupedIngredientList />
    </FixedHeaderFooter>
}

module.exports = IngredientSelectionView
