_     = require 'lodash'
React = require 'react/addons'

stylingConstants = require './stylingConstants'

DOM_NODE = document.querySelector '#web-clip-notification'

WebClipNotification = React.createClass {
  displayName : 'WebClipNotification'

  render : ->
    <div className='web-clip-notification arrow-box hidden' onTouchTap={@_dismiss}>
      <span className='request'>
        <span className='lead-in'>
          Hey there first-timer!
        </span>
        Tap <img src='/img/ios-export.png'/> to save Spirit Guide to your home screen.
        That gets rid of the top and bottom bars, to boot!
      </span>
      <br/>
      <span className='dismiss'>
        Tap this note to dismiss it permanently.
      </span>
    </div>

  componentDidMount : ->
    _.defer =>
      @getDOMNode().classList.remove 'hidden'

  _dismiss : ->
    @getDOMNode().classList.add 'hidden'
    DOM_NODE.classList.add 'hidden'
    _.delay (=>
      React.unmountComponentAtNode DOM_NODE
    ), stylingConstants.TRANSITION_DURATION

}

LOCALSTORAGE_KEY = 'drinks-app-web-clip-notification'

module.exports = {
  renderIfAppropriate : ->
    if window.navigator.userAgent.indexOf('iPhone') != -1 and not localStorage[LOCALSTORAGE_KEY] and not window.navigator.standalone
      localStorage[LOCALSTORAGE_KEY] = true
      DOM_NODE.classList.remove 'hidden'
      React.render <WebClipNotification/>, DOM_NODE
}
