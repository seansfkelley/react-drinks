_        = require 'lodash'
React    = require 'react'
ReactDom = require 'react-dom'

stylingConstants = require '../../stylingConstants'

DOM_NODE = document.querySelector '#web-clip-notification'

WebClipNotification = React.createClass {
  displayName : 'WebClipNotification'

  render : ->
    <div className='web-clip-notification arrow-box hidden' onTouchTap={@_dismiss}>
      <span className='request'>
        <span className='lead-in'>
          Hey there first-timer!
        </span>
        Tap <img src='/assets/img/ios-export.png'/> to save Spirit Guide to your home screen.
        That gets rid of the top and bottom bars, to boot!
      </span>
      <br/>
      <span className='dismiss'>
        Tap this note to dismiss it permanently.
      </span>
    </div>

  componentDidMount : ->
    _.defer =>
      ReactDom.findDOMNode(@).classList.remove 'hidden'

  _dismiss : ->
    ReactDom.findDOMNode(@).classList.add 'hidden'
    DOM_NODE.classList.add 'hidden'
    _.delay (=>
      ReactDom.unmountComponentAtNode DOM_NODE
    ), stylingConstants.TRANSITION_DURATION

}

IS_IPHONE = window.navigator.userAgent.indexOf('iPhone') != -1
LOCALSTORAGE_KEY = 'drinks-app-web-clip-notification'

module.exports = {
  renderIfAppropriate : ->
    if IS_IPHONE and not localStorage[LOCALSTORAGE_KEY] and not window.navigator.standalone
      localStorage[LOCALSTORAGE_KEY] = true
      DOM_NODE.classList.remove 'hidden'
      ReactDom.render <WebClipNotification/>, DOM_NODE
}
