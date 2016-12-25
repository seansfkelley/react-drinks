import * as Bluebird from 'bluebird';

export const PROXY_BLUEBIRD_PROMISE: ProxyHandler<any> = {
  get: (target, name) => {
    if (typeof target[name] === 'function') {
      return (...args: any[]) => {
        const result = target[name](...args);
        if (result && typeof result.then === 'function') {
          return Bluebird.resolve(result);
        } else {
          return result;
        }
      };
    } else {
      return target[name];
    }
  }
};

export const PROXY_RETRY: ProxyHandler<any> = {
  get: (target, name) => {
    if (typeof target[name] === 'function') {
      return (...args: any[]) => {
        const retryHelper = (retries: number): any => {
          function retryOrThrow(error?: any) {
            if (retries > 0) {
              return retryHelper(retries - 1);
            } else {
              throw error;
            }
          }

          let result;
          try {
            result = target[name](...args);
          } catch (error) {
            return retryOrThrow(error);
          }

          if (result && typeof result.then === 'function') {
            return result.then((resolved: any) => resolved, retryOrThrow);
          } else {
            return result;
          }
        }

        return retryHelper(1);
      };
    } else {
      return target[name];
    }
  }
};
