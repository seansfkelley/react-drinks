import { mapValues, get } from 'lodash';

export default (state, pathsByField) => mapValues(pathsByField, path => get(state, path));
