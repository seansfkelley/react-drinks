import { isSymbol } from 'lodash';

const EXEMPTIONS = [
  // Lodash methods will look for these fields when duck-typing:
  'length', 'constructor', 'prototype',
  // Chai methods will look for these fields when formatting log lines:
  'inspect', 'nodeType'
];

export function makePartialProxy<T>(obj: Partial<T>): T {
  return new Proxy<Partial<T>>(obj, {
    get: (target: Partial<T>, name: keyof T) => {
      if (isSymbol(name) || target.hasOwnProperty(name) || EXEMPTIONS.indexOf(name) !== -1) {
        return target[name];
      } else {
        throw new Error(`mock object was asked for field '${name.toString()}' which it did not define`);
      }
    }
  }) as T;
}
