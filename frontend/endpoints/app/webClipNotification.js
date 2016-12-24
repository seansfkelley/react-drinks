_        = require 'lodash'
React    = require 'react'
ReactDOM = require 'react-dom'

stylingConstants = require '../../stylingConstants'

DOM_NODE = document.querySelector '#web-clip-notification'

WebClipNotification = React.createClass {
  displayName : 'WebClipNotification'

  render : ->
    React.createElement("div", {"className": 'web-clip-notification arrow-box hidden', "onTouchTap": (@_dismiss)},
      React.createElement("span", {"className": 'request'},
        React.createElement("span", {"className": 'lead-in'}, "Hey there first-timer!"), "Tap",
          React.createElement("img", {"src": '/assets/img/ios-export.png'}), """ to save Spirit Guide to your home screen.
        That gets rid of the top and bottom bars, to boot!"""),
      React.createElement("br", null),
      React.createElement("span", {"className": 'dismiss'}, "Tap this note to dismiss it permanently.")
    )

  componentDidMount : ->
    _.defer =>
      ReactDOM.findDOMNode(@).classList.remove 'hidden'

  _dismiss : ->
    ReactDOM.findDOMNode(@).classList.add 'hidden'
    DOM_NODE.classList.add 'hidden'
    _.delay (=>
      ReactDOM.unmountComponentAtNode DOM_NODE
    ), stylingConstants.TRANSITION_DURATION

}

IS_IPHONE = window.navigator.userAgent.indexOf('iPhone') != -1
LOCALSTORAGE_KEY = 'drinks-app-web-clip-notification'

module.exports = {
  renderIfAppropriate : ->
    if IS_IPHONE and not localStorage[LOCALSTORAGE_KEY] and not window.navigator.standalone
      localStorage[LOCALSTORAGE_KEY] = true
      DOM_NODE.classList.remove 'hidden'
      ReactDOM.render React.createElement(WebClipNotification, null), DOM_NODE
}
