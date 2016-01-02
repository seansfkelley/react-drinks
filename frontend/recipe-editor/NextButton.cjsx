React      = require 'react'
classnames = require 'classnames'

NextButton = React.createClass {
  displayName : 'NextButton'

  propTypes :
    onNext    : React.PropTypes.func
    text      : React.PropTypes.string
    isEnabled : React.PropTypes.bool

  getDefaultProps : -> {
    text      : 'Next'
    isEnabled : true
  }

  render : ->
    <div className={classnames 'next-button', { 'disabled' : not @props.isEnabled }} onTouchTap={@_nextIfEnabled}>
      <span className='next-text'>{@props.text}</span>
      <i className='fa fa-arrow-right'/>
    </div>

  _nextIfEnabled : ->
    if @props.isEnabled
      @props.onNext()
}

module.exports = NextButton
