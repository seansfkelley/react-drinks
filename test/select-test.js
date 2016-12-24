const select = require('../frontend/store/derived/select');

describe('select', function() {
  it('should shallowly select non-primitive items', function() {
    const obj = {};
    const arr = [];
    const result = select({
      one : obj,
      two : arr
    }, {
      a : 'one',
      b : 'two'
    });
    result.should.have.property('a', obj);
    return result.should.have.property('b', arr);
  });

  it('should select nested properties using a dot-separated syntax', () =>
    select({
      top : {
        middle : {
          bottom : 1337
        }
      }
    }, {
      value : 'top.middle.bottom'
    }).should.deep.equal({
      value : 1337
    }));

  return it('should select multiple values from the same source field', function() {
    const field = {
      one   : 1,
      two   : 2,
      three : {
        nested : 'stuff'
      }
    };
    return select({ field }, {
      everything   : 'field',
      number       : 'field.one',
      deeplyNested : 'field.three.nested'
    }).should.deep.equal({
      everything   : field,
      number       : 1,
      deeplyNested : 'stuff'
    });});});
