const React           = require('react');
const classnames      = require('classnames');
const PureRenderMixin = require('react-addons-pure-render-mixin');

const SearchBar = React.createClass({
  displayName : 'SearchBar',

  propTypes : {
    onChange     : React.PropTypes.func.isRequired,
    initialValue : React.PropTypes.string,
    placeholder  : React.PropTypes.string
  },

  mixins : [ PureRenderMixin ],

  getInitialState() { return {
    value : this.props.initialValue != null ? this.props.initialValue : ''
  }; },

  render() {
    return React.createElement("div", {"className": (classnames('search-bar', this.props.className)), "onTouchStart": (this._stopTouchStart)},
      React.createElement("i", {"className": 'fa fa-search'}),
      React.createElement("input", { 
        "type": 'text',  
        "className": 'search-input',  
        "placeholder": (this.props.placeholder),  
        "value": (this.state.value),  
        "onChange": (this._onChange),  
        "onTouchTap": (this.focus),  
        "ref": 'input',  
        "tabIndex": -1,  
        "autoCorrect": 'off',  
        "autoCapitalize": 'off',  
        "autoComplete": 'off',  
        "spellCheck": 'false'
      }),
      (this.state.value.length ? React.createElement("i", {"className": 'fa fa-times-circle', "onTouchTap": (this.clearAndFocus), "onTouchStart": (this._stopTouchStart)}) : undefined)
    );
  },

  clearAndFocus() {
    this.clear();
    return this.focus();
  },

  clear() {
    this.setState({ value : '' });
    return this.props.onChange('');
  },

  focus() {
    return this.refs.input.focus();
  },

  isFocused() {
    return document.activeElement === this.refs.input;
  },

  _onChange(e) {
    this.setState({ value : e.target.value });
    return this.props.onChange(e.target.value);
  },

  _stopTouchStart(e) {
    // This is hacky, but both of these are independently necessary.
    // 1. Stop propagation so that the App-level handler doesn't deselect the input on clear.
    e.stopPropagation();
    // 2. Prevent default so that iOS doesn't reassign the active element and deselect the input.
    return e.preventDefault();
  }
});

module.exports = SearchBar;
