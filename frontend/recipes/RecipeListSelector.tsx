import { without, flatten } from 'lodash';
import * as React from 'react';
import * as classNames from 'classnames';
import * as PureRenderMixin from 'react-addons-pure-render-mixin';

import { store } from '../store';

import { RECIPE_LIST_TYPES, RECIPE_LIST_NAMES } from '../../shared/definitions';

interface Props {
  currentType?: string;
  onClose?: Function;
}

export default React.createClass<Props, void>({
  displayName: 'RecipeListSelector',

  mixins: [PureRenderMixin],

  render() {
    const reorderedOptions = flatten([this.props.currentType, without(RECIPE_LIST_TYPES, this.props.currentType)]);
    const options = reorderedOptions.map(type => (
      <div
        key={type}
        className={classNames('option', { 'is-selected': type === this.props.currentType })}
        onClick={this._onOptionSelect.bind(null, type)}
      >
        <span className='label'>{(RECIPE_LIST_NAMES as any)[type]}</span>
      </div>
    ));

    return <div className='recipe-list-selector'>{options}</div>;
  },

  _onOptionSelect(listType: string) {
    store.dispatch({
      type: 'set-selected-recipe-list',
      listType
    });
    this.props.onClose();
  }
});


