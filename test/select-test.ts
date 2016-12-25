import { expect } from 'chai';

import select from '../frontend/store/derived/select';

describe('select', () => {
  it('should shallowly select non-primitive items', () => {
    const obj = {};
    const arr: any[] = [];
    const result = select({
      one: obj,
      two: arr
    }, {
      a: 'one',
      b: 'two'
    });

    expect(result).to.have.property('a', obj);
    expect(result).to.have.property('b', arr);
  });

  it('should select nested properties using a dot-separated syntax', () => {
    expect(select({
      top: {
        middle: {
          bottom: 1337
        }
      }
    }, {
      value: 'top.middle.bottom'
    })).to.deep.equal({
      value: 1337
    });
  });

  it('should select multiple values from the same source field', () => {
    const field = {
      one: 1,
      two: 2,
      three: {
        nested: 'stuff'
      }
    };

    expect(select({ field }, {
      everything: 'field',
      number: 'field.one',
      deeplyNested: 'field.three.nested'
    })).to.deep.equal({
      everything: field,
      number: 1,
      deeplyNested: 'stuff'
    });
  });
});

