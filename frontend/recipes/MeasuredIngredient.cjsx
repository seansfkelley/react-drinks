React      = require 'react/addons'
classnames = require 'classnames'
{ PureRenderMixin } = React.addons

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
    <div className={classnames 'measured-ingredient', @props.className, {
        'missing'     : @props.isMissing
        'substituted' : @props.isSubstituted
    }}>
      <span className='measure'>
        <span className='amount'>{utils.fractionify @props.displayAmount}</span>
        {' '}
        <span className='unit'>{@props.displayUnit}</span>
      </span>
      <span className='ingredient'>
        <span className='name'>{@props.displayIngredient}</span>
      {if @props.displaySubstitutes.length
        [
          <span className='substitute-label' key='label'>try:</span>
          <span className='substitute-content' key='content'>{@props.displaySubstitutes}</span>
        ]}
      {if @props.difficulty
        <span className={classnames 'difficulty', Difficulty.CLASS_NAME[@props.difficulty]}>
          {Difficulty.HUMAN_READABLE[@props.difficulty]}
        </span>}
      </span>
    </div>
}

module.exports = MeasuredIngredient
