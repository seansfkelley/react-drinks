import {} from 'lodash';

module.exports = (state, pathsByField) => _.mapValues(pathsByField, path => _.get(state, path));
