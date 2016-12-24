const React           = require('react');
const classnames      = require('classnames');
const PureRenderMixin = require('react-addons-pure-render-mixin');

const utils = require('../utils');

const Difficulty = require('../Difficulty');

const MeasuredIngredient = React.createClass({
  displayName : 'MeasuredIngredient',

  mixins : [ PureRenderMixin ],

  propTypes : {
    displayAmount      : React.PropTypes.string,
    displayUnit        : React.PropTypes.string,
    displayIngredient  : React.PropTypes.string.isRequired,
    displaySubstitutes : React.PropTypes.array,
    isMissing          : React.PropTypes.bool,
    isSubstituted      : React.PropTypes.bool,
    difficulty         : React.PropTypes.string
  },

  getDefaultProps() { return {
    displayAmount      : '',
    displayUnit        : '',
    displaySubstitutes : []
  }; },

  render() {
    // The space is necessary to space out the spans from each other. Newlines are insufficient.
    // Include the keys only to keep React happy so that it warns us about significant uses of
    // arrays without key props.
    return React.createElement("div", {"className": (classnames('measured-ingredient', this.props.className, {
        'missing'     : this.props.isMissing,
        'substituted' : this.props.isSubstituted
    }))},
      React.createElement("span", {"className": 'measure'},
        React.createElement("span", {"className": 'amount'}, (utils.fractionify(this.props.displayAmount))),
        (' '),
        React.createElement("span", {"className": 'unit'}, (this.props.displayUnit))
      ),
      React.createElement("span", {"className": 'ingredient'},
        React.createElement("span", {"className": 'name'}, (this.props.displayIngredient)),
      (this.props.displaySubstitutes.length ? [
        React.createElement("span", {"className": 'substitute-label', "key": 'label'}, "try:"),
        React.createElement("span", {"className": 'substitute-content', "key": 'content'}, (this.props.displaySubstitutes))
      ] : undefined),
      (this.props.difficulty ? React.createElement("span", {"className": (classnames('difficulty', Difficulty.CLASS_NAME[this.props.difficulty]))},
        (Difficulty.HUMAN_READABLE[this.props.difficulty])
      ) : undefined)
      )
    );
  }
});

module.exports = MeasuredIngredient;
