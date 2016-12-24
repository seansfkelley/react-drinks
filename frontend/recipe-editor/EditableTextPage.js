const React           = require('react');
const classnames      = require('classnames');
const PureRenderMixin = require('react-addons-pure-render-mixin');

const store = require('../store');

const ReduxMixin = require('../mixins/ReduxMixin');

const EditableRecipePage = require('./EditableRecipePage');

const EditableTextPage = React.createClass({
  displayName : 'EditableTextPage',

  mixins : [
    ReduxMixin({
      editableRecipe : [ 'instructions', 'notes' ]
    })
  ],

  propTypes : {
    onClose       : React.PropTypes.func.isRequired,
    onNext        : React.PropTypes.func,
    onPrevious    : React.PropTypes.func,
    previousTitle : React.PropTypes.string
  },

  render() {
    return React.createElement(EditableRecipePage, { 
      "className": 'text-page',  
      "onClose": (this.props.onClose),  
      "onPrevious": (this.props.onPrevious),  
      "previousTitle": (this.props.previousTitle)
    },
      React.createElement("div", {"className": 'fixed-content-pane'},
        React.createElement("textarea", { 
          "className": 'editable-text-area',  
          "placeholder": 'Instructions...',  
          "onChange": (this._setInstructions),  
          "value": (this.state.instructions),  
          "ref": 'instructions'
        }),
        React.createElement("textarea", { 
          "className": 'editable-text-area',  
          "placeholder": 'Notes (optional)...',  
          "onChange": (this._setNotes),  
          "value": (this.state.notes),  
          "ref": 'notes'
        }),
        React.createElement("div", {"className": (classnames('next-button', { 'disabled' : !this._isEnabled() })), "onTouchTap": (this._nextIfEnabled)},
          React.createElement("span", {"className": 'next-text'}, "Next"),
          React.createElement("i", {"className": 'fa fa-arrow-right'})
        )
      )
    );
  },

  _isEnabled() {
    return this.state.instructions.length;
  },

  _nextIfEnabled() {
    if (this._isEnabled()) {
      return this.props.onNext();
    }
  },

  _setInstructions(e) {
    return store.dispatch({
      type         : 'set-instructions',
      instructions : e.target.value
    });
  },

  _setNotes(e) {
    return store.dispatch({
      type  : 'set-notes',
      notes : e.target.value
    });
  }
});

module.exports = EditableTextPage;
