# @cjsx React.DOM

React = require 'react'

NewRecipePage = require './NewRecipePage'

appRootElement = document.querySelector '#app-root'

React.render <NewRecipePage/>, appRootElement
