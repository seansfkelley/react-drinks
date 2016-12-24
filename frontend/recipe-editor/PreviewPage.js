const React           = require('react');
const PureRenderMixin = require('react-addons-pure-render-mixin');

const EditableRecipePage = require('./EditableRecipePage');

const RecipeView = require('../recipes/RecipeView');

const PreviewPage = React.createClass({
  displayName : 'PreviewPage',

  propTypes : {
    onClose       : React.PropTypes.func.isRequired,
    onNext        : React.PropTypes.func,
    onPrevious    : React.PropTypes.func,
    previousTitle : React.PropTypes.string,
    recipe        : React.PropTypes.object,
    isSaving      : React.PropTypes.bool
  },

  mixins : [
    PureRenderMixin
  ],

  render() {
    let nextButton;
    if (this.props.isSaving) {
      nextButton = React.createElement("div", {"className": 'next-button fixed-footer'},
        React.createElement("span", {"className": 'next-text'}, "Saving"),
        React.createElement("i", {"className": 'fa fa-refresh fa-spin'})
      );
    } else {
      nextButton = React.createElement("div", {"className": 'next-button fixed-footer', "onTouchTap": (this.props.onNext)},
        React.createElement("span", {"className": 'next-text'}, "Done"),
        React.createElement("i", {"className": 'fa fa-check'})
      );
    }

    return React.createElement(EditableRecipePage, { 
      "className": 'preview-page',  
      "onClose": (this.props.onClose),  
      "onPrevious": (this.props.onPrevious),  
      "previousTitle": (this.props.previousTitle)
    },
      React.createElement("div", {"className": 'fixed-content-pane'},
        React.createElement(RecipeView, {"recipe": (this.props.recipe)})
      ),
      (nextButton)
    );
  }
});

module.exports = PreviewPage;
