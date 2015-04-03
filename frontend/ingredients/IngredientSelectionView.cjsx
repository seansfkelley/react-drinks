# @cjsx React.DOM

_     = require 'lodash'
React = require 'react'

FluxMixin        = require '../mixins/FluxMixin'
AppDispatcher    = require '../AppDispatcher'
stylingConstants = require '../stylingConstants'

{ IngredientStore, UiStore } = require '../stores'

List              = require '../components/List'
TitleBar          = require '../components/TitleBar'
FixedHeaderFooter = require '../components/FixedHeaderFooter'
SearchBar         = require '../components/SearchBar'

IngredientSelectionHeader = React.createClass {
  displayName : 'IngredientSelectionHeader'

  propTypes :
    onClose : React.PropTypes.func

  render : ->
    <TitleBar
      leftIcon='fa-chevron-down'
      leftIconOnTouchTap={@props.onClose}
      title='Ingredients'
    />
}

IngredientGroupHeader = React.createClass {
  displayName : 'IngredientGroupHeader'

  propTypes :
    title         : React.PropTypes.string.isRequired
    selectedCount : React.PropTypes.number.isRequired

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

  propTypes :
    title : React.PropTypes.string.isRequired

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

  propTypes :
    ingredient : React.PropTypes.object.isRequired

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

  propTypes :
    searchedGroupedIngredients : React.PropTypes.array
    selectedIngredientTags     : React.PropTypes.object

  render : ->
    tagToGroupName = {}
    for { name, ingredients} in @props.searchedGroupedIngredients
      for i in ingredients
        tagToGroupName[i.tag] = name

    ingredientNodes = _.chain @props.searchedGroupedIngredients
      .map ({ ingredients }) => _.map ingredients, (i) -> <IngredientListItem ingredient={i} key={i.tag}/>
      .flatten()
      .value()

    if not ingredientNodes.length
      listNodes = []
    else if ingredientNodes.length < 10
      sortedIngredientNodes = _.sortBy ingredientNodes, (n) -> n.props.ingredient.displayName
      selectedCount = _.chain ingredientNodes
        .filter (i) => @props.selectedIngredientTags[i.props.ingredient.tag]?
        .value()
        .length
      listNodes = [
        <IngredientGroupHeader
          title="All Results (#{ingredientNodes.length})"
          selectedCount={selectedCount}
          key='header-all-results'
        />
      ].concat sortedIngredientNodes
    else
      listNodes = List.headerify {
        nodes             : ingredientNodes
        Header            : IngredientGroupHeader
        ItemGroup         : IngredientItemGroup
        computeHeaderData : (node, i) =>
          title         = tagToGroupName[node.props.ingredient.tag]
          selectedCount = _.chain @props.searchedGroupedIngredients
            .where { name : title }
            .value()[0]
            .ingredients
            .filter (i) => @props.selectedIngredientTags[i.tag]?
            .length
          return {
            title
            selectedCount
            key : 'header-' + title
          }
      }

    className = "#{List.ClassNames.HEADERED} #{List.ClassNames.COLLAPSIBLE} ingredient-list"
    <List className={className} emptyText='Nothing matched your search.'>
      {listNodes}
    </List>
}

IngredientSelectionView = React.createClass {
  displayName : 'IngredientSelectionView'

  propTypes : {}

  mixins : [
    FluxMixin IngredientStore, 'searchedGroupedIngredients', 'selectedIngredientTags'
  ]

  render : ->
    <FixedHeaderFooter
      className='ingredient-selection-view'
      header={<IngredientSelectionHeader onClose={@_onClose}/>}
      ref='container'
    >
      <SearchBar className='list-topper' placeholder='Ingredient name...' onChange={@_onSearch}/>
      <GroupedIngredientList {...@state}/>
    </FixedHeaderFooter>

  componentDidMount : ->
    @refs.container.scrollTo 44

  # In the future, this should pop up a loader and then throttle the number of filters performed.
  _onSearch : (searchTerm) ->
    AppDispatcher.dispatch {
      type : 'search-ingredients'
      searchTerm
    }

  _onClose : ->
    AppDispatcher.dispatch {
      type : 'hide-flyup'
    }
    AppDispatcher.dispatch {
      type       : 'search-ingredients'
      searchTerm : ''
    }
}


module.exports = IngredientSelectionView
