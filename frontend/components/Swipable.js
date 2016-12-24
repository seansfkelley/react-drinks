const _               = require('lodash');
const React           = require('react');
const ReactDOM        = require('react-dom');
const classnames      = require('classnames');
const PureRenderMixin = require('react-addons-pure-render-mixin');

const IntertialSwipeLogicBox = require('./IntertialSwipeLogicBox');

const InertialSwipable = React.createClass({
  displayName : 'InertialSwipable',

  propTypes : {
    onSwiping       : React.PropTypes.func,
    onSwiped        : React.PropTypes.func,
    initialDelta    : React.PropTypes.number,
    getNearestIndex : React.PropTypes.func,
    itemOffsets     : React.PropTypes.array.isRequired,
    friction        : React.PropTypes.number
  },

  mixins : [ PureRenderMixin ],

  render() {
    return React.createElement("div", { 
      "onTouchStart": (this._onTouchStart),  
      "onTouchMove": (this._onTouchMove),  
      "onTouchEnd": (this._onTouchEnd),  
      "className": (classnames('inertial-swipable', this.props.className))
    },
      (this.props.children)
    );
  },

  _onTouchStart(e) {
    return this._logicBox.onTouchStart(e);
  },

  _onTouchMove(e) {
    return this._logicBox.onTouchMove(e);
  },

  _onTouchEnd(e) {
    return this._logicBox.onTouchEnd(e);
  },

  componentDidMount() {
    return this._logicBox = new IntertialSwipeLogicBox({
      itemOffsets     : this.props.itemOffsets,
      getNearestIndex : this.props.getNearestIndex,
      onChangeDelta   : this.props.onSwiping,
      onFinish        : this.props.onSwiped,
      initialDelta    : this.props.initialDelta,
      amplitudeFactor : this.props.friction ? 1 - this.props.friction : undefined
    });
  },

  componentWillReceiveProps(nextProps) {
    if (!_.isEqual(nextProps.itemOffsets, this.props.itemOffsets)) {
      __guard__(this._logicBox, x => x.destroy());
      return this._logicBox = new IntertialSwipeLogicBox({
        itemOffsets     : nextProps.itemOffsets,
        getNearestIndex : this.props.getNearestIndex,
        onChangeDelta   : nextProps.onSwiping,
        onFinish        : nextProps.onSwiped,
        initialDelta    : nextProps.initialDelta,
        amplitudeFactor : this.props.friction ? 1 - this.props.friction : undefined
      });
    } else if (nextProps.initialDelta !== this.props.initialDelta) {
      return __guard__(this._logicBox, x1 => x1.setDeltaInstantly(nextProps.initialDelta));
    }
  },

  componentWillUnmount() {
    return __guard__(this._logicBox, x => x.destroy());
  }
});


const Swipable = React.createClass({
  displayName : 'Swipable',

  propTypes : {
    initialIndex  : React.PropTypes.number,
    onSlideChange : React.PropTypes.func,
    friction      : React.PropTypes.number
  },

  mixins : [ PureRenderMixin ],

  getInitialState() {
    const zeroes = _.map(_.range(React.Children.count(this.props.children)), () => 0);
    return {
      wrapperWidth : 0,
      itemWidths   : zeroes,
      itemOffsets  : zeroes,
      delta        : 0,
      initialDelta : 0
    };
  },

  _getIndexForDelta(delta) {
    // return _.sortedIndex(@state.itemOffsets, delta)
    const shiftedOffsets = _.chain()
      .range(this.state.itemOffsets.length)
      .map(i => this.state.itemOffsets[i] - (this.state.itemWidths[i] / 2))
      .value();
    // Why is this -1 again?
    return Math.max(0, _.sortedIndex(shiftedOffsets, delta) - 1);
  },

  render() {
    const offset = -this.state.delta + ((this.state.wrapperWidth - this.state.itemWidths[0]) / 2);

    return React.createElement(InertialSwipable, { 
      "onSwiping": (this._onSwiping),  
      "onSwiped": (this._onSwiped),  
      "itemOffsets": (this.state.itemOffsets),  
      "initialDelta": (this.state.initialDelta),  
      "getNearestIndex": (this._getNearestIndex),  
      "friction": (this.props.friction),  
      "className": (classnames('viewport-container', this.props.className)),  
      "ref": 'inertialSwipable'
    },
      React.createElement("div", { 
        "className": 'sliding-container',  
        "ref": 'slidingContainer',  
        "style": ({
          WebkitTransform : `translateX(${offset}px) translateZ(0)`, // Hardware acceleration.
          transform       : `translateX(${offset}px)`
        })
      },
        (this.props.children)
      )
    );
  },

  componentDidMount() {
    this._computeCachedState();

    window.addEventListener('orientationchange', this._computeCachedState, false);
    return window.addEventListener('resize', this._computeCachedState, false);
  },

  componentWillUnmount() {
    window.removeEventListener('orientationchange', this._computeCachedState);
    return window.removeEventListener('resize', this._computeCachedState);
  },

  _computeCachedState() {
    const wrapperWidth = this.refs.slidingContainer.offsetWidth;
    const itemWidths   = _.pluck(this.refs.slidingContainer.children, 'offsetWidth');
    const itemOffsets  = _.chain(itemWidths)
      .reduce((function(offsets, width) {
        offsets.push(_.last(offsets) + width);
        return offsets;
      }), [ 0 ])
      .initial()
      .value();
    const initialDelta = itemOffsets[this.props.initialIndex != null ? this.props.initialIndex : 0];
    return this.setState({ wrapperWidth, itemWidths, itemOffsets, initialDelta });
  },

  _getNearestIndex(e) {
    let { target } = e;
    while ((target != null) && target.parentNode !== this.refs.slidingContainer) {
      target = target.parentNode;
    }
    if (target) {
      return _.indexOf(this.refs.slidingContainer.children, target);
    } else {
      const { offsetLeft, offsetWidth } = ReactDOM.findDOMNode(this.refs.inertialSwipable);
      if ((e.changedTouches[0].clientX - offsetLeft) < offsetWidth / 2) {
        return 0;
      } else {
        return this.refs.slidingContainer.children.length - 1;
      }
    }
  },

  _onSwiping(delta) {
    const oldIndex = this._getIndexForDelta(this.state.delta);
    const newIndex = this._getIndexForDelta(delta);
    this.setState({ delta });
    if (oldIndex !== newIndex) {
      return this.props.onSlideChange(newIndex);
    }
  },

  _onSwiped() {
    const index = this._getIndexForDelta(this.state.delta);
    return this.setState({ initialDelta : this.state.itemOffsets[index] });
  }
    // Leaving this here for posterity, but, I think it's a safe bet
    // that the index hasn't changed between the last onSwiping call
    // and this, so don't call it twice in a row.
    // @props.onSlideChange index
});

module.exports = Swipable;

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}