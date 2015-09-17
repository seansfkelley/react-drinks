React      = require 'react/addons'
classnames = require 'classnames'

{ PureRenderMixin } = React.addons

List = require '../components/List'

Difficulty = require '../Difficulty'

HUMAN_READABLE_DIFFICULTIES = {
  "#{difficulty.Difficulty.EASY}"   : 'Easy'
  "#{difficulty.Difficulty.MEDIUM}" : 'Medium'
  "#{difficulty.Difficulty.HARD}"   : 'Hard'
}

RecipeListItem = React.createClass {
  displayName : 'RecipeListItem'

  propTypes :
    recipeName : React.PropTypes.string.isRequired
    difficulty : React.PropTypes.string
    onTouchTap : React.PropTypes.func
    onDelete   : React.PropTypes.func

  mixins : [ PureRenderMixin ]

  render : ->
    if @props.difficulty
      difficultyNode = <span className='difficulty'>{@props.mixability}</span>

    ListItemClass = if @props.onDelete? then List.DeletableItem else List.Item

    <ListItemClass
      className={classnames 'recipe-list-item', { 'is-mixable' : @props.mixability == 0 }}
      onTouchTap={@props.onTouchTap}
      onDelete={@props.onDelete}
    >
      <span className='name'>{@props.recipeName}</span>
      {difficultyNode}
    </ListItemClass>
}

module.exports = RecipeListItem
