const React           = require('react');
const classnames      = require('classnames');
const PureRenderMixin = require('react-addons-pure-render-mixin');

const List = require('../components/List');

const Difficulty = require('../Difficulty');

const RecipeListItem = React.createClass({
  displayName : 'RecipeListItem',

  propTypes : {
    recipeName : React.PropTypes.string.isRequired,
    difficulty : React.PropTypes.string,
    isMixable  : React.PropTypes.bool,
    onTouchTap : React.PropTypes.func,
    onDelete   : React.PropTypes.func
  },

  mixins : [ PureRenderMixin ],

  getDefaultProps() { return {
    isMixable : true
  }; },

  render() {
    let difficultyNode;
    if (this.props.difficulty) {
      difficultyNode = React.createElement("span", {"className": (classnames('difficulty', Difficulty.CLASS_NAME[this.props.difficulty]))},
        (Difficulty.HUMAN_READABLE[this.props.difficulty])
      );
    }

    const ListItemClass = (this.props.onDelete != null) ? List.DeletableItem : List.Item;

    return React.createElement(ListItemClass, { 
      "className": (classnames('recipe-list-item', { 'is-mixable' : this.props.isMixable })),  
      "onTouchTap": (this.props.onTouchTap),  
      "onDelete": (this.props.onDelete)
    },
      React.createElement("span", {"className": 'name'}, (this.props.recipeName)),
      (difficultyNode)
    );
  }
});

module.exports = RecipeListItem;
