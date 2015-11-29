_          = require 'lodash'
React      = require 'react'
classnames = require 'classnames'

store = require '../store'

NavigationHeader = React.createClass {
  displayName : 'NavigationHeader'

  propTypes :
    onClose       : React.PropTypes.func.isRequired
    previousTitle : React.PropTypes.string
    onPrevious    : React.PropTypes.func

  render : ->
    <div className='navigation-header fixed-header'>
      {if @props.previousTitle and @props.onPrevious
        <div className='back-button float-left' onTouchTap={@props.onPrevious}>
          <i className='fa fa-chevron-left'/>
          <span className='back-button-label'>{@props.previousTitle}</span>
        </div>}
      <i className='fa fa-times float-right' onTouchTap={@_close}/>
    </div>

  _close : ->
    store.dispatch {
      type : 'clear-editable-recipe'
    }

    @props.onClose()
}

EditableRecipePage = React.createClass {
  displayName : 'EditableRecipePage'

  propTypes :
    onClose       : React.PropTypes.func.isRequired
    onPrevious    : React.PropTypes.func
    previousTitle : React.PropTypes.string
    className     : React.PropTypes.string

  render : ->
    <div className={classnames 'editable-recipe-page fixed-header-footer', @props.className}>
      <NavigationHeader onClose={@props.onClose} previousTitle={@props.previousTitle} onPrevious={@props.onPrevious}/>
      {@props.children}
    </div>
}

module.exports = EditableRecipePage
