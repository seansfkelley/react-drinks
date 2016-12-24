require('../common-init')();

const React    = require('react');
const ReactDOM = require('react-dom');

const StandaloneRecipe = require('./StandaloneRecipe');

const APP_ROOT = document.querySelector('#app-root');

// TODO: Redirect to nonexistent error page if this is mangled.
ReactDOM.render(React.createElement(StandaloneRecipe, {"recipe": (window.recipeData)}), APP_ROOT);
