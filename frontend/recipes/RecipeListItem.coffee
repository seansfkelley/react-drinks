React           = require 'react'
classnames      = require 'classnames'
PureRenderMixin = require 'react-addons-pure-render-mixin'

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
      difficultyNode = React.createElement("span", {"className": (classnames 'difficulty', Difficulty.CLASS_NAME[@props.difficulty])},
        (Difficulty.HUMAN_READABLE[@props.difficulty])
      )

    ListItemClass = if @props.onDelete? then List.DeletableItem else List.Item

    React.createElement(ListItemClass, { \
      "className": (classnames 'recipe-list-item', { 'is-mixable' : @props.isMixable }),  \
      "onTouchTap": (@props.onTouchTap),  \
      "onDelete": (@props.onDelete)
    },
      React.createElement("span", {"className": 'name'}, (@props.recipeName)),
      (difficultyNode)
    )
}

module.exports = RecipeListItem
