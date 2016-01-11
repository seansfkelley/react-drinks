React      = require 'react'
classnames = require 'classnames'

IdEntry = React.createClass {
  displayName : 'IdEntry'

  propTypes :
    value     : React.PropTypes.string.isRequired
    onChange  : React.PropTypes.func.isRequired
    isValid   : React.PropTypes.bool.isRequired
    isLoading : React.PropTypes.bool.isRequired
    className : React.PropTypes.string

  render : ->
    <div className={classnames 'id-entry', @props.className}>
      <div className='instruction'>Enter Code</div>
      <input
        type='text'
        placeholder='Code...'
        autoCorrect='off'
        autoCapitalize='false'
        autoComplete='off'
        spellCheck='false'
        ref='idInput'
        value={@props.value}
        onChange={@_onChange}
        onTouchTap={@_focus}
      />
      {if @props.isLoading
        <i className='fa fa-spin fa-refresh'/>}
      {if not @props.isValid
        <div className='invalid-message'>Oops! Looks like that code doesn't exist.</div>}
    </div>

  _onChange : (e) ->
    @props.onChange e.target.value.trim()

  _focus : ->
    @refs.idInput.focus()
}

module.exports = IdEntry
