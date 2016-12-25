import { every } from 'lodash';

export function memoize<I extends {}, O>(fn: (input: I) => O): (input: I) => O {
  let lastArg: I | undefined;
  let lastResult: O | undefined;

  return (arg: I) => {
    if (every(arg, (value, key) => lastArg != null && (lastArg as any)![key!] === value)) {
      return lastResult!;
    } else {
      lastArg = arg;
      lastResult = fn(arg);
      return lastResult!;
    }
  };
};
