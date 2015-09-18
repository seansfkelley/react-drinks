React      = require 'react/addons'
classnames = require 'classnames'

{ PureRenderMixin } = React.addons

List = require '../components/List'

Difficulty = require '../Difficulty'

RecipeListItem = React.createClass {
  displayName : 'RecipeListItem'

  propTypes :
    recipeName : React.PropTypes.string.isRequired
    difficulty : React.PropTypes.string
    isMixable  : React.PropTypes.bool
    onTouchTap : React.PropTypes.func
    onDelete   : React.PropTypes.func

  mixins : [ PureRenderMixin ]

  getDefaultProps : -> {
    isMixable : true
  }

  render : ->
    if @props.difficulty
      difficultyNode = <span className={classnames 'difficulty', Difficulty.CLASS_NAME[@props.difficulty]}>
        {Difficulty.HUMAN_READABLE[@props.difficulty]}
      </span>

    ListItemClass = if @props.onDelete? then List.DeletableItem else List.Item

    <ListItemClass
      className={classnames 'recipe-list-item', { 'is-mixable' : @props.isMixable }}
      onTouchTap={@props.onTouchTap}
      onDelete={@props.onDelete}
    >
      <span className='name'>{@props.recipeName}</span>
      {difficultyNode}
    </ListItemClass>
}

module.exports = RecipeListItem
