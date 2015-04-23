# @cjsx React.DOM

_     = require 'lodash'
React = require 'react/addons'

FluxMixin = require '../mixins/FluxMixin'

List              = require '../components/List'
TitleBar          = require '../components/TitleBar'
FixedHeaderFooter = require '../components/FixedHeaderFooter'
SearchBar         = require '../components/SearchBar'

AppDispatcher                = require '../AppDispatcher'
stylingConstants             = require '../stylingConstants'
{ IngredientStore, UiStore } = require '../stores'


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
    isSelected : React.PropTypes.bool.isRequired
    ingredient : React.PropTypes.object.isRequired
    toggle     : React.PropTypes.func.isRequired

  render : ->
    if @props.isSelected
      className = 'is-selected'

    <List.Item className={className} onTouchTap={@_toggleIngredient}>
      <div className='name'>{@props.ingredient.display}</div>
      <i className='fa fa-check-circle has-ingredient-icon'/>
    </List.Item>

  _toggleIngredient : ->
    @props.toggle @props.ingredient.tag
    # AppDispatcher.dispatch {
    #   type : 'toggle-ingredient'
    #   tag  : @props.ingredient.tag
    # }
}

GroupedIngredientList = React.createClass {
  display : 'GroupedIngredientList'

  propTypes :
    searchedGroupedIngredients    : React.PropTypes.array
    initialSelectedIngredientTags : React.PropTypes.object

  getInitialState : -> {
    selectedIngredientTags : @props.initialSelectedIngredientTags
  }

  render : ->
    ingredientCount = _.chain @props.searchedGroupedIngredients
      .pluck 'ingredients'
      .pluck 'length'
      .reduce ((sum, n) -> sum + n), 0
      .value()

    if ingredientCount == 0
      listNodes = []
    else if ingredientCount < 10
      ingredients = _.chain @props.searchedGroupedIngredients
        .pluck 'ingredients'
        .flatten()
        .sortBy 'displayName'
        .value()

      selectedCount = _.filter(ingredients, (i) => @state.selectedIngredientTags[i.tag]?).length

      header = <IngredientGroupHeader
        title="All Results (#{ingredientNodes.length})"
        selectedCount={selectedCount}
        key='header-all-results'
      />

      listNodes = [
        header
        _.map ingredients, (i) -> <IngredientListItem ingredient={i} key={i.tag}/>
      ]

    else
      listNodes = []
      for { name, ingredients } in @props.searchedGroupedIngredients
        ingredientNodes = []
        selectedCount = 0
        for i in ingredients
          ingredientNodes.push <IngredientListItem
            ingredient={i}
            isSelected={@state.selectedIngredientTags[i.tag]?}
            toggle={@_toggleIngredient}
            key={i.tag}
          />
          if @state.selectedIngredientTags[i.tag]?
            selectedCount += 1
        listNodes.push [
          <IngredientGroupHeader
            title={name}
            selectedCount={selectedCount}
            key={'header-' + name}
          />
          <IngredientItemGroup title={name} key={'group-' + name}>{ingredientNodes}</IngredientItemGroup>
        ]

    className = "#{List.ClassNames.HEADERED} #{List.ClassNames.COLLAPSIBLE} ingredient-list"
    <List className={className} emptyText='Nothing matched your search.'>
      {listNodes}
    </List>

  _toggleIngredient : (tag) ->
    # alternately, use a local store + dispatcher!? rather than state
    # just don't apply the changes until comit
    if @state.selectedIngredientTags[tag]?
      delete @state.selectedIngredientTags[tag]
    else
      @state.selectedIngredientTags[tag] = true
    @setState { selectedIngredientTags : @state.selectedIngredientTags }
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
      <GroupedIngredientList
        searchedGroupedIngredients={@state.searchedGroupedIngredients}
        initialSelectedIngredientTags={@state.selectedIngredientTags}
        ref='ingredientList'
      />
    </FixedHeaderFooter>

  componentDidMount : ->
    @refs.container.scrollTo stylingConstants.INGREDIENTS_LIST_ITEM_HEIGHT

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
    AppDispatcher.dispatch {
      type : 'set-selected-ingredient-tags'
      selectedIngredientTags : @refs.ingredientList.state.selectedIngredientTags
    }
}


module.exports = IngredientSelectionView
