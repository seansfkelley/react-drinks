const _ = require('lodash');
const React = require('react');
const Draggable = require('react-draggable');
const classnames = require('classnames');

const DELETABLE_WIDTH = 80;

const Deletable = React.createClass({
  displayName: 'Deletable',

  propTypes: {
    onDelete: React.PropTypes.func.isRequired,
    children: React.PropTypes.element.isRequired
  },

  getInitialState() {
    return {
      initialX: 0,
      deltaX: 0,
      checkFirstMove: true,
      ignoreDrag: false
    };
  },

  render() {
    const renderableProps = _.omit(this.props, 'onDelete');
    const left = DELETABLE_WIDTH - Math.abs(this.state.left);
    return <Draggable axis='x' bounds={{ left: -DELETABLE_WIDTH, right: 0 }} onStart={this._onDragStart} onDrag={this._onDrag} onStop={this._onDragEnd} ref='draggable'><div className={classnames('deletable', this.props.className)}>{this.props.children}<div className='delete-button' style={{ width: Math.abs(this.state.deltaX), right: this.state.deltaX }} onTouchTap={this._onDelete}><span className='text' style={{ width: DELETABLE_WIDTH }}>Delete</span></div></div></Draggable>;
  },

  _onDelete(e) {
    e.stopPropagation();
    return this.props.onDelete();
  },

  _onDragStart(e, { position }) {
    // Do NOT reset deltaX -- it may be dragged open already.
    return this.setState({ initialX: position.left, checkFirstMove: true, ignoreDrag: false });
  },

  _onDrag(event, { deltaX, deltaY }) {
    if (this.state.ignoreDrag) {
      return false;
    } else if (this.state.checkFirstMove && Math.abs(deltaY) > Math.abs(deltaX)) {
      this.setState({ ignoreDrag: true });
      return false;
    } else {
      this.setState({ deltaX: Math.min(Math.max(this.state.deltaX + deltaX, -DELETABLE_WIDTH), 0) });
    }
    return this.setState({ checkFirstMove: false });
  },

  _onDragEnd(event, { position }) {
    if (this.state.deltaX < -DELETABLE_WIDTH / 2) {
      this.refs.draggable.setState({ clientX: -DELETABLE_WIDTH });
      return this.setState({ deltaX: -DELETABLE_WIDTH });
    } else {
      this.refs.draggable.setState({ clientX: 0 });
      return this.setState({ deltaX: 0 });
    }
  }
});

module.exports = Deletable;