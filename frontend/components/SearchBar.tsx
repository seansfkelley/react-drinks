import * as React from 'react';
import * as classNames from 'classnames';
import * as PureRenderMixin from 'react-addons-pure-render-mixin';

interface Props {
  onChange: Function;
  initialValue?: string;
  placeholder?: string;
  className?: string;
}

interface State {
  value: string;
}

export default React.createClass<Props, State>({
  displayName: 'SearchBar',

  propTypes: {
    onChange: React.PropTypes.func.isRequired,
    initialValue: React.PropTypes.string,
    placeholder: React.PropTypes.string
  },

  mixins: [PureRenderMixin],

  getInitialState() {
    return {
      value: this.props.initialValue != null ? this.props.initialValue : ''
    };
  },

  render() {
    return (
      <div className={classNames('search-bar', this.props.className)} onTouchStart={this._stopTouchStart}>
        <i className='fa fa-search' />
        <input
          type='text'
          className='search-input'
          placeholder={this.props.placeholder}
          value={this.state.value}
          onChange={this._onChange}
          onClick={this.focus}
          ref='input'
          tabIndex={-1}
          autoCorrect='off'
          autoCapitalize='off'
          autoComplete='off'
          spellCheck={false}
        />
        {this.state.value.length
          ? <i className='fa fa-times-circle' onClick={this.clearAndFocus} onTouchStart={this._stopTouchStart} />
          : null}
      </div>
    );
  },

  clearAndFocus() {
    this.clear();
    this.focus();
  },

  clear() {
    this.setState({ value: '' });
    this.props.onChange('');
  },

  focus() {
    this.refs.input.focus();
  },

  isFocused() {
    return document.activeElement === this.refs.input;
  },

  _onChange(e: React.FormEvent<HTMLInputElement>) {
    this.setState({ value: e.currentTarget.value });
    this.props.onChange(e.currentTarget.value);
  },

  _stopTouchStart(e: React.TouchEvent<void>) {
    // This is hacky, but both of these are independently necessary.
    // 1. Stop propagation so that the App-level handler doesn't deselect the input on clear.
    e.stopPropagation();
    // 2. Prevent default so that iOS doesn't reassign the active element and deselect the input.
    e.preventDefault();
  }
});


