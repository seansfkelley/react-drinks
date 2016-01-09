_          = require 'lodash'
React      = require 'react'
classnames = require 'classnames'

ButtonBar = React.createClass {
  displayName : 'ButtonBar'

  propTypes :
    buttons : React.PropTypes.arrayOf(React.PropTypes.shape({
      icon       : React.PropTypes.string
      text       : React.PropTypes.string
      onTouchTap : React.PropTypes.func
    })).isRequired
    className : React.PropTypes.string

  render : ->
    buttons = _.map @props.buttons, (button, i) ->
      <div className='button' onTouchTap={button.onTouchTap} key={i}>
        <i className={classnames 'fa', button.icon}/>
        <div className='text'>{button.text}</div>
      </div>

    <div className='button-bar'>
      {buttons}
    </div>
}

module.exports = ButtonBar
