import { assign, clone } from 'lodash';
import { expect } from 'chai';
import * as Bluebird from 'bluebird';

import { PROXY_BLUEBIRD_PROMISE, PROXY_RETRY } from '../backend/proxies';

function makeCountingGetProxy<T>(proxyable: T, handler: ProxyHandler<T>): { proxy: T, getCount: () => number } {
  let getCount = 0;
  const countingHandler: ProxyHandler<T> = assign({}, handler, {
    get: (target, name, receiver) => {
      getCount++;
      return handler.get!(target, name, receiver);
    }
  });
  return {
    proxy: new Proxy(assign({},proxyable), countingHandler),
    getCount: () => getCount
  };
}

describe('(proxies)', () => {
  describe('Bluebird promisification proxy', () => {
    it('should forward the arguments to the function', () => {
      let capturedArgs;
      const proxyable = {
        fn: (...args) => {
          capturedArgs = args;
        }
      };

      const { proxy, getCount } = makeCountingGetProxy(proxyable, PROXY_BLUEBIRD_PROMISE);

      proxy.fn(1, 'a', {});
      expect(getCount()).to.equal(1);
      expect(capturedArgs).to.deep.equal([ 1, 'a', {} ]);
    });

    it('should intercept a function that returns a native promise', () => {
      const proxyable = {
        fn: () => new Promise(() => {})
      };

      const { proxy, getCount } = makeCountingGetProxy(proxyable, PROXY_BLUEBIRD_PROMISE);

      expect(proxy.fn()).to.be.an.instanceOf(Bluebird);
      expect(getCount()).to.equal(1);
    });

    it('should intercept a function that returns a Bluebird promise', () => {
      const proxyable = {
        fn: () => Bluebird.resolve()
      };

      const { proxy, getCount } = makeCountingGetProxy(proxyable, PROXY_BLUEBIRD_PROMISE);

      expect(proxy.fn()).to.be.an.instanceOf(Bluebird);
      expect(getCount()).to.equal(1);
    });

    // This is actually not desirable, but it seems like we should explicitly state that this is known behavior.
    it('should intercept a function that returns a object with a `then` field that is a function', () => {
      const proxyable = {
        fn: () => ({ then: () => {} })
      };

      const { proxy, getCount } = makeCountingGetProxy(proxyable, PROXY_BLUEBIRD_PROMISE);

      expect(proxy.fn()).to.be.an.instanceOf(Bluebird);
      expect(getCount()).to.equal(1);
    });

    it('should not intercept a function that returns a object with a `then` field that is not a function', () => {
      const proxyable = {
        fn: () => ({ then: 'what' })
      };

      const { proxy, getCount } = makeCountingGetProxy(proxyable, PROXY_BLUEBIRD_PROMISE);

      expect(proxy.fn()).to.deep.equal({ then: 'what' });
      expect(getCount()).to.equal(1);
    });

    it('should not intercept functions that do not return a promise', () => {
      const proxyable = {
        fn: () => 'result'
      };

      const { proxy, getCount } = makeCountingGetProxy(proxyable, PROXY_BLUEBIRD_PROMISE);

      expect(proxy.fn()).to.equal('result');
      expect(getCount()).to.equal(1);
    });

    it('should not intercept non-function accesses', () => {
      const proxyable = {
        foo: 'bar'
      };

      const { proxy, getCount } = makeCountingGetProxy(proxyable, PROXY_BLUEBIRD_PROMISE);

      expect(proxy.foo).to.equal('bar');
      expect(getCount()).to.equal(1);
    });
  });

  describe('retrying proxy', () => {
    it('should forward the arguments to the function', () => {
      let capturedArgs;
      const proxyable = {
        fn: (...args) => {
          capturedArgs = args;
        }
      };

      const { proxy, getCount } = makeCountingGetProxy(proxyable, PROXY_BLUEBIRD_PROMISE);

      proxy.fn(1, 'a', {});
      expect(getCount()).to.equal(1);
      expect(capturedArgs).to.deep.equal([ 1, 'a', {} ]);
    });

    it('should forward the same arguments repeatedly when retrying', () => {
      let capturedArgs: any[] = [];
      const proxyable = {
        fn: (...args) => {
          capturedArgs.push(args);
          throw new Error();
        }
      };

      const { proxy, getCount } = makeCountingGetProxy(proxyable, PROXY_RETRY);

      try {
        proxy.fn(1, 'a', {});
      } catch (e) {
        // don't care, just capturing the arguments
      }
      expect(getCount()).to.equal(1);
      expect(capturedArgs).to.deep.equal([
        [ 1, 'a', {} ],
        [ 1, 'a', {} ]
      ]);
    });

    it('should retry a function call that synchronously throws', () => {
      let callCount = 0;
      const proxyable = {
        fn: () => {
          callCount++;
          if (callCount === 1) {
            throw new Error();
          } else {
            return 'success';
          }
        }
      };

      const { proxy, getCount } = makeCountingGetProxy(proxyable, PROXY_RETRY);

      expect(proxy.fn()).to.equal('success');
      expect(callCount).to.equal(2);
      expect(getCount()).to.equal(1);
    });

    it('should not retry a function call that synchronously returns a non-promise', () => {
      let callCount = 0;
      const proxyable = {
        fn: () => {
          callCount++;
          return 'success';
        }
      };

      const { proxy, getCount } = makeCountingGetProxy(proxyable, PROXY_RETRY);

      expect(proxy.fn()).to.equal('success');
      expect(callCount).to.equal(1);
      expect(getCount()).to.equal(1);
    });

    it('should rethrow the error synchronously if the function repeatedly synchronously throws', () => {
      let callCount = 0;
      const proxyable = {
        fn: () => {
          callCount++;
          throw new Error();
        }
      };

      const { proxy, getCount } = makeCountingGetProxy(proxyable, PROXY_RETRY);

      expect(() => proxy.fn()).to.throw();
      expect(callCount).to.equal(2);
      expect(getCount()).to.equal(1);
    });

    it('should retry a function that returns a rejected promise', () => {
      let callCount = 0;
      const proxyable = {
        fn: () => {
          callCount++;
          if (callCount === 1) {
            return Promise.reject(new Error());
          } else {
            return Promise.resolve('success');
          }
        }
      };

      const { proxy, getCount } = makeCountingGetProxy(proxyable, PROXY_RETRY);

      return proxy.fn()
        .then(result => {
          expect(result).to.equal('success');
          expect(callCount).to.equal(2);
          expect(getCount()).to.equal(1);
        });
    });

    it('should not retry a function that returns a resolved promise', () => {
      let callCount = 0;
      const proxyable = {
        fn: () => {
          callCount++;
          return Promise.resolve('success');
        }
      };

      const { proxy, getCount } = makeCountingGetProxy(proxyable, PROXY_RETRY);

      return proxy.fn()
        .then(result => {
          expect(result).to.equal('success');
          expect(callCount).to.equal(1);
          expect(getCount()).to.equal(1);
        });
    });

    it('should return a rejected promise if the function repeatedly rejects', () => {
      let callCount = 0;
      const proxyable = {
        fn: () => {
          callCount++;
          return Promise.reject(new Error());
        }
      };

      const { proxy, getCount } = makeCountingGetProxy(proxyable, PROXY_RETRY);

      return proxy.fn()
        .then(
          result => { throw new Error('promise should have rejected!') },
          error => { /* do nothing, this is expected */ }
        )
        .then(() => {
          expect(callCount).to.equal(2);
          expect(getCount()).to.equal(1);
        });
    });

    it('should return a rejected promise if the function sychronously throws THEN rejects', () => {
      let callCount = 0;
      const proxyable = {
        fn: () => {
          callCount++;
          if (callCount === 1) {
            throw 'sync';
          } else {
            return Promise.reject('async');
          }
        }
      };

      const { proxy, getCount } = makeCountingGetProxy(proxyable, PROXY_RETRY);

      return proxy.fn()
        .then(
          result => { throw new Error('promise should have rejected!') },
          error => { expect(error).to.equal('async') }
        )
        .then(() => {
          expect(callCount).to.equal(2);
          expect(getCount()).to.equal(1);
        });
    });

    it('should return a rejected promise if the function rejects THEN sychronously throws', () => {
      let callCount = 0;
      const proxyable = {
        fn: () => {
          callCount++;
          if (callCount === 1) {
            return Promise.reject('async');
          } else {
            throw 'sync';
          }
        }
      };

      const { proxy, getCount } = makeCountingGetProxy(proxyable, PROXY_RETRY);

      return proxy.fn()
        .then(
          result => { throw new Error('promise should have rejected!') },
          error => { expect(error).to.equal('sync') }
        )
        .then(() => {
          expect(callCount).to.equal(2);
          expect(getCount()).to.equal(1);
        });
    });

    it('should return a promise for a function that rejects THEN synchronously returns', () => {
      let callCount = 0;
      const proxyable = {
        fn: () => {
          callCount++;
          if (callCount === 1) {
            return Promise.reject(new Error());
          } else {
            return 'success';
          }
        }
      };

      const { proxy, getCount } = makeCountingGetProxy(proxyable, PROXY_RETRY);

      return proxy.fn()
        .then(result => {
          expect(result).to.equal('success');
          expect(callCount).to.equal(2);
          expect(getCount()).to.equal(1);
        });
    });

    it('should not intercept non-function accessors', () => {
      const proxyable = {
        foo: 'bar'
      };

      const { proxy, getCount } = makeCountingGetProxy(proxyable, PROXY_BLUEBIRD_PROMISE);

      expect(proxy.foo).to.equal('bar');
      expect(getCount()).to.equal(1);
    });
  });
});
