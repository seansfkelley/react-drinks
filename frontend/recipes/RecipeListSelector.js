const _               = require('lodash');
const React           = require('react');
const classnames      = require('classnames');
const PureRenderMixin = require('react-addons-pure-render-mixin');

const store = require('../store');

const definitions = require('../../shared/definitions');

const RecipeListSelector = React.createClass({
  displayName : 'RecipeListSelector',

  propTypes : {
    currentType : React.PropTypes.string,
    onClose     : React.PropTypes.func
  },

  mixins : [ PureRenderMixin ],

  render() {
    const reorderedOptions = _.flatten([
      this.props.currentType,
      _.without(definitions.RECIPE_LIST_TYPES, this.props.currentType)
    ]);

    const options = _.map(reorderedOptions, type => {
      return React.createElement("div", { 
        "key": (type),  
        "className": (classnames('option', { 'is-selected' : type === this.props.currentType })),  
        "onTouchTap": (this._onOptionSelect.bind(null, type))
      },
        React.createElement("span", {"className": 'label'}, (definitions.RECIPE_LIST_NAMES[type]))
      );
    }
    );

    return React.createElement("div", {"className": 'recipe-list-selector'},
      (options)
    );
  },

  _onOptionSelect(listType) {
    store.dispatch({
      type : 'set-selected-recipe-list',
      listType
    });
    return this.props.onClose();
  }
});

module.exports = RecipeListSelector;
