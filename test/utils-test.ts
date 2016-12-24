import {} from 'lodash';

const utils = require('../frontend/utils');

describe('utils', () => describe('#splitMeasure', function () {
  const GOOD_TEST_CASES = [{
    input: undefined,
    output: {
      unit: ''
    }
  }, {
    input: '',
    output: {
      unit: ''
    }
  }, {
    input: '1',
    output: {
      measure: '1',
      unit: ''
    }
  }, {
    input: '1 ounce',
    output: {
      measure: '1',
      unit: 'ounce'
    }
  }, {
    input: '1/2 ounce',
    output: {
      measure: '1/2',
      unit: 'ounce'
    }
  }, {
    input: '1 1/2 ounce',
    output: {
      measure: '1 1/2',
      unit: 'ounce'
    }
  }, {
    input: '1-2 dashes',
    output: {
      measure: '1-2',
      unit: 'dashes'
    }
  }, {
    input: '1/2 - 1 scoops',
    output: {
      measure: '1/2 - 1',
      unit: 'scoops'
    }
  }, {
    input: '1 - 1 1/2 scoops',
    output: {
      measure: '1 - 1 1/2',
      unit: 'scoops'
    }
  }];

  const BAD_TEST_CASES = [{
    input: '1 to 2 dashes',
    output: {
      measure: '1',
      unit: 'to 2 dashes'
    }
  }];

  const ALL_TEST_CASES = GOOD_TEST_CASES.concat(BAD_TEST_CASES);

  return _.each(ALL_TEST_CASES, function ({ input, output }) {
    const { unit, measure } = output;
    const outputString = ('{ ' + _.compact([measure != null ? `measure : ${ JSON.stringify(measure) }` : undefined, unit != null ? `unit : ${ JSON.stringify(unit) }` : undefined]).join(', ') + ' }').replace(/\s+/g, ' ');
    return it(`should return ${ outputString } for input ${ JSON.stringify(input) }`, () => utils.splitMeasure(input).should.deep.equal(output));
  });
}));

