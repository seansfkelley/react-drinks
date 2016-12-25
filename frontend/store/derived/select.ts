import { mapValues, get } from 'lodash';

export default function<T>(state: T, pathsByField: { [field: string]: string }): { [field: string]: any } {
  return mapValues(pathsByField, path => get(state, path));
}
