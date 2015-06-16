React      = require 'react/addons'
classnames = require 'classnames'

{ PureRenderMixin } = React.addons

List = require '../components/List'

RecipeListItem = React.createClass {
  displayName : 'RecipeListItem'

  propTypes :
    recipeName : React.PropTypes.string.isRequired
    mixability : React.PropTypes.number
    onTouchTap : React.PropTypes.func
    onDelete   : React.PropTypes.func

  mixins : [ PureRenderMixin ]

  render : ->
    if @props.mixability > 0
      mixabilityNode = <span className='mixability'>{@props.mixability}</span>

    ListItemClass = if @props.onDelete? then List.DeletableItem else List.Item

    <ListItemClass className={classnames 'recipe-list-item', { 'is-mixable' : @props.mixability == 0 }} onTouchTap={@props.onTouchTap} onDelete={@props.onDelete}>
      <span className='name'>{@props.recipeName}</span>
      {mixabilityNode}
    </ListItemClass>
}

module.exports = RecipeListItem
