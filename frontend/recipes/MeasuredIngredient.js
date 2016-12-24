const React = require('react');
const classnames = require('classnames');
const PureRenderMixin = require('react-addons-pure-render-mixin');

const utils = require('../utils');

const Difficulty = require('../Difficulty');

const MeasuredIngredient = React.createClass({
  displayName: 'MeasuredIngredient',

  mixins: [PureRenderMixin],

  propTypes: {
    displayAmount: React.PropTypes.string,
    displayUnit: React.PropTypes.string,
    displayIngredient: React.PropTypes.string.isRequired,
    displaySubstitutes: React.PropTypes.array,
    isMissing: React.PropTypes.bool,
    isSubstituted: React.PropTypes.bool,
    difficulty: React.PropTypes.string
  },

  getDefaultProps() {
    return {
      displayAmount: '',
      displayUnit: '',
      displaySubstitutes: []
    };
  },

  render() {
    // The space is necessary to space out the spans from each other. Newlines are insufficient.
    // Include the keys only to keep React happy so that it warns us about significant uses of
    // arrays without key props.
    return <div className={classnames('measured-ingredient', this.props.className, {
      'missing': this.props.isMissing,
      'substituted': this.props.isSubstituted
    })}><span className='measure'><span className='amount'>{utils.fractionify(this.props.displayAmount)}</span> <span className='unit'>{this.props.displayUnit}</span></span><span className='ingredient'><span className='name'>{this.props.displayIngredient}</span>{this.props.displaySubstitutes.length ? [<span className='substitute-label' key='label'>try:</span>, <span className='substitute-content' key='content'>{this.props.displaySubstitutes}</span>] : undefined}{this.props.difficulty ? <span className={classnames('difficulty', Difficulty.CLASS_NAME[this.props.difficulty])}>{Difficulty.HUMAN_READABLE[this.props.difficulty]}</span> : undefined}</span></div>;
  }
});

module.exports = MeasuredIngredient;