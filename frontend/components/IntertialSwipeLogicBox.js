const _ = require('lodash');

const assert = require('../../shared/tinyassert');

const TIME_CONSTANT = 150;

const CaptureType = {
  INDETERMINATE: -1,
  NO: 0,
  YES: 1
};

class IntertialSwipeLogicBox {
  constructor({
    itemOffsets,
    initialDelta,
    getNearestIndex,
    onChangeDelta,
    onFinish,
    amplitudeFactor
  }) {
    this.onTouchStart = this.onTouchStart.bind(this);
    this.onTouchMove = this.onTouchMove.bind(this);
    this.onTouchEnd = this.onTouchEnd.bind(this);
    this.setDeltaInstantly = this.setDeltaInstantly.bind(this);
    this._set = this._set.bind(this);
    this._trackVelocity = this._trackVelocity.bind(this);
    this._computeResistance = this._computeResistance.bind(this);
    this._uncomputeResistance = this._uncomputeResistance.bind(this);
    this._isInRange = this._isInRange.bind(this);
    this.itemOffsets = itemOffsets;
    this.initialDelta = initialDelta;
    this.getNearestIndex = getNearestIndex;
    this.onChangeDelta = onChangeDelta;
    this.onFinish = onFinish;
    this.amplitudeFactor = amplitudeFactor;
    assert(this.itemOffsets);
    assert(this.getNearestIndex);

    this._set({
      trueDelta: this.initialDelta != null ? this.initialDelta : 0,
      visibleDelta: this.initialDelta != null ? this.initialDelta : 0,
      amplitudeFactor: this.amplitudeFactor != null ? this.amplitudeFactor : 0.5,
      captureType: null,
      initialTouchX: null,
      initialTouchY: null,
      lastX: null,
      lastTrackedTime: null,
      lastTrackedDelta: null,
      lastTrackedVelocity: null
    });
  }

  onTouchStart(e) {
    if (e.touches.length > 1) {
      return;
    }

    if (this._animFrame != null) {
      cancelAnimationFrame(this._animFrame);
    }

    this._set({
      captureType: CaptureType.INDETERMINATE,
      initialTouchX: e.touches[0].clientX,
      initialTouchY: e.touches[0].clientY,
      lastX: e.touches[0].clientX,
      lastTrackedTime: Date.now(),
      lastTrackedDelta: this.visibleDelta,
      lastTrackedVelocity: 0
    });

    return this._interval = setInterval(this._trackVelocity, 50);
  }

  onTouchMove(e) {
    if (e.touches.length > 1 || this.captureType === CaptureType.NO) {
      return;
    }

    if (this.captureType === CaptureType.INDETERMINATE) {
      const dx = Math.abs(this.initialTouchX - e.changedTouches[0].clientX);
      const dy = Math.abs(this.initialTouchY - e.changedTouches[0].clientY);
      if (dx < 5) {
        // Jitter, don't do anything yet cause it could be a tap.
        return;
      } else if (dx < dy) {
        // Obviously, this implies we can only swip horizontal. Fine for now.
        this._set({ captureType: CaptureType.NO });
        return;
      } else {
        // Now we're swiping!
        this._set({ captureType: CaptureType.YES });
      }
    }

    // Prevent scrolling: if you drag horizontally and then vertically in one motion, you'll scroll and swip.
    e.preventDefault();

    const trueDelta = this.trueDelta - (e.changedTouches[0].clientX - this.lastX);
    const visibleDelta = this._computeResistance(trueDelta);

    return this._set({
      trueDelta,
      visibleDelta,
      lastX: e.changedTouches[0].clientX
    });
  }

  onTouchEnd(e) {
    if (e.touches.length > 1) {
      return;
    }

    clearInterval(this._interval);

    if (this.captureType === CaptureType.NO) {
      this._autoScroll({ target: this.itemOffsets[this.getNearestIndex(e)] });
      return;
    }

    this.onTouchMove(e);
    this._set({
      lastX: null,
      lastTrackedTime: null,
      lastTrackedDelta: null
    });

    const distance = e.changedTouches[0].clientX - this.initialTouchX;
    // Tap, rather than swipe.
    if (Math.abs(distance) < 10) {
      return this._autoScroll({ target: this.itemOffsets[this.getNearestIndex(e)] });
    } else {
      return this._autoScroll({ amplitude: this.amplitudeFactor * this.lastTrackedVelocity });
    }
  }

  // TODO: We probably actually want to animate this.
  setDeltaInstantly(delta) {
    assert(this._isInRange(delta));

    return this._set({
      visibleDelta: delta,
      trueDelta: delta
    });
  }

  _set(fields) {
    if (fields.visibleDelta != null && fields.visibleDelta !== this.visibleDelta) {
      __guardMethod__(this, 'onChangeDelta', o => o.onChangeDelta(fields.visibleDelta));
    }

    return _.extend(this, fields);
  }

  _trackVelocity() {
    const now = Date.now();
    const elapsed = now - this.lastTrackedTime;

    const v = 1000 * (this.visibleDelta - this.lastTrackedDelta) / (1 + elapsed);

    return this._set({
      lastTrackedTime: now,
      lastTrackedDelta: this.visibleDelta,
      lastTrackedVelocity: 0.8 * v + 0.2 * this.lastTrackedVelocity
    });
  }

  _computeResistance(trueDelta) {
    if (trueDelta > _.last(this.itemOffsets)) {
      const overflow = trueDelta - _.last(this.itemOffsets);
      return _.last(this.itemOffsets) + Math.sqrt(overflow) * 4;
    } else if (trueDelta < 0) {
      return -Math.sqrt(Math.abs(trueDelta)) * 4;
    } else {
      return trueDelta;
    }
  }

  _uncomputeResistance(visibleDelta) {
    if (visibleDelta > _.last(this.itemOffsets)) {
      const overflow = visibleDelta - _.last(this.itemOffsets);
      return _.last(this.itemOffsets) + Math.pow(overflow / 4, 2);
    } else if (visibleDelta < 0) {
      return -Math.pow(Math.abs(visibleDelta) / 4, 2);
    } else {
      return visibleDelta;
    }
  }

  _isInRange(value) {
    return 0 <= value && value <= _.last(this.itemOffsets);
  }

  _snapToNearestOffset(value) {
    const i = _.sortedIndex(this.itemOffsets, value);
    if (i === 0) {
      return _.first(this.itemOffsets);
    } else if (i === this.itemOffsets.length) {
      return _.last(this.itemOffsets);
    } else if (Math.abs(value - this.itemOffsets[i - 1]) < Math.abs(value - this.itemOffsets[i])) {
      return this.itemOffsets[i - 1];
    } else {
      return this.itemOffsets[i];
    }
  }

  _autoScroll({ amplitude, target }) {
    let trueDelta, visibleDelta;
    assert(amplitude != null !== (target != null), 'exactly one of amplitude or target must be specified');

    if (!this._isInRange(this.visibleDelta)) {
      this._bounceBackIfNecessary();
      return;
    }

    if (target == null) {
      target = this.trueDelta + amplitude;
    }

    if (this._isInRange(target)) {
      target = this._snapToNearestOffset(target);
    }

    amplitude = target - this.trueDelta;

    return this._animate({
      amplitude,

      onStep: stepDelta => {
        trueDelta = target + stepDelta;
        visibleDelta = this._computeResistance(trueDelta);

        if (Math.abs(visibleDelta - this.visibleDelta) < 5 && !this._isInRange(this.visibleDelta)) {
          this._set({ trueDelta, visibleDelta });
          // cancelAnimationFrame?
          delete this._animFrame;
          this._bounceBackIfNecessary();
          return false;
        } else {
          return this._set({ trueDelta, visibleDelta });
        }
      },

      onFinish: () => {
        this._set({
          trueDelta: target,
          visibleDelta: target
        });
        return __guardMethod__(this, 'onFinish', o => o.onFinish());
      }
    });
  }

  _bounceBackIfNecessary() {
    let target, trueDelta, visibleDelta;
    if (this.visibleDelta < 0) {
      target = 0;
    } else if (this.visibleDelta > _.last(this.itemOffsets)) {
      target = _.last(this.itemOffsets);
    } else {
      target = this.visibleDelta;
    }

    return this._animate({
      amplitude: target - this.visibleDelta,

      onStep: stepDelta => {
        visibleDelta = target + stepDelta;
        trueDelta = this._uncomputeResistance(visibleDelta);
        return this._set({ trueDelta, visibleDelta });
      },

      onFinish: () => {
        this._set({
          trueDelta: target,
          visibleDelta: target
        });
        return __guardMethod__(this, 'onFinish', o => o.onFinish());
      }
    });
  }

  _animate({ amplitude, onStep, onFinish }) {
    const startTime = Date.now();
    const _step = () => {
      const elapsed = Date.now() - startTime;
      const stepDelta = -amplitude * Math.exp(-elapsed / TIME_CONSTANT);
      if (stepDelta < -1 || stepDelta > 1) {
        // Must literally return false. Note that this will NOT call onFinish.
        if (onStep(stepDelta) !== false) {
          return this._animFrame = requestAnimationFrame(_step);
        }
      } else {
        __guardFunc__(onFinish, f => f());
        return delete this._animFrame;
      }
    };

    return this._animFrame = requestAnimationFrame(_step);
  }

  destroy() {
    cancelAnimationFrame(this._animFrame);
    return clearInterval(this._interval);
  }
}

module.exports = IntertialSwipeLogicBox;

function __guardMethod__(obj, methodName, transform) {
  if (typeof obj !== 'undefined' && obj !== null && typeof obj[methodName] === 'function') {
    return transform(obj, methodName);
  } else {
    return undefined;
  }
}
function __guardFunc__(func, transform) {
  return typeof func === 'function' ? transform(func) : undefined;
}