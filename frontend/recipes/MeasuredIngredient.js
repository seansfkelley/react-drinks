React           = require 'react'
classnames      = require 'classnames'
PureRenderMixin = require 'react-addons-pure-render-mixin'

utils = require '../utils'

Difficulty = require '../Difficulty'

MeasuredIngredient = React.createClass {
  displayName : 'MeasuredIngredient'

  mixins : [ PureRenderMixin ]

  propTypes :
    displayAmount      : React.PropTypes.string
    displayUnit        : React.PropTypes.string
    displayIngredient  : React.PropTypes.string.isRequired
    displaySubstitutes : React.PropTypes.array
    isMissing          : React.PropTypes.bool
    isSubstituted      : React.PropTypes.bool
    difficulty         : React.PropTypes.string

  getDefaultProps : -> {
    displayAmount      : ''
    displayUnit        : ''
    displaySubstitutes : []
  }

  render : ->
    # The space is necessary to space out the spans from each other. Newlines are insufficient.
    # Include the keys only to keep React happy so that it warns us about significant uses of
    # arrays without key props.
    React.createElement("div", {"className": (classnames 'measured-ingredient', @props.className, {
        'missing'     : @props.isMissing
        'substituted' : @props.isSubstituted
    })},
      React.createElement("span", {"className": 'measure'},
        React.createElement("span", {"className": 'amount'}, (utils.fractionify @props.displayAmount)),
        (' '),
        React.createElement("span", {"className": 'unit'}, (@props.displayUnit))
      ),
      React.createElement("span", {"className": 'ingredient'},
        React.createElement("span", {"className": 'name'}, (@props.displayIngredient)),
      (if @props.displaySubstitutes.length then [
        React.createElement("span", {"className": 'substitute-label', "key": 'label'}, "try:")
        React.createElement("span", {"className": 'substitute-content', "key": 'content'}, (@props.displaySubstitutes))
      ]),
      (if @props.difficulty then React.createElement("span", {"className": (classnames 'difficulty', Difficulty.CLASS_NAME[@props.difficulty])},
        (Difficulty.HUMAN_READABLE[@props.difficulty])
      ))
      )
    )
}

module.exports = MeasuredIngredient
