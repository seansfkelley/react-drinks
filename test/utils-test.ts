import { expect } from 'chai';

import { splitMeasure, UnitWithMeasure } from '../frontend/utils';

describe('utils', () => {
  describe('#splitMeasure', () => {
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

    const ALL_TEST_CASES: { input: string | undefined, output: UnitWithMeasure }[] = GOOD_TEST_CASES.concat(BAD_TEST_CASES);

    ALL_TEST_CASES.forEach(({ input, output }) => {
      const { unit, measure } = output;
      const outputString = ('{ ' + [
        measure != null ? `measure : ${JSON.stringify(measure)}` : undefined,
        unit != null ? `unit : ${JSON.stringify(unit)}` : undefined
      ].filter(s => !!s).join(', ') + ' }').replace(/\s+/g, ' ');

      it(`should return ${outputString} for input ${JSON.stringify(input)}`, () => {
        expect(splitMeasure(input)).to.deep.equal(output);
      });
    });
  });
});

