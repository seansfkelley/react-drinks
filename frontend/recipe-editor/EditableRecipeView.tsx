
import * as React from 'react';

import ReduxMixin from '../mixins/ReduxMixin';

import normalization from '../../shared/normalization';

import store from '../store';
import EditableRecipePageType from '../EditableRecipePageType';

import definitions from '../../shared/definitions';

import EditableNamePage from './EditableNamePage';
import EditableIngredientsPage from './EditableIngredientsPage';
import EditableBaseLiquorPage from './EditableBaseLiquorPage';
import EditableTextPage from './EditableTextPage';
import PreviewPage from './PreviewPage';

import editableRecipeActions from './editableRecipeActions';

// TODO: make IconButton class?
// TODO: clicking back into ingredients to edit them
// TODO: show what "type of" it is in the final display
// TODO: "oh you put numbers in" (re: instructions); "I didn't know that it would do the numbers as you go in"
// TODO: clicking on something to edit could be nice
// TODO: "done" button is rather far away

export default React.createClass({
  displayName: 'EditableRecipeView',

  propTypes: {
    onClose: React.PropTypes.func.isRequired
  },

  mixins: [ReduxMixin({
    editableRecipe: ['currentPage', 'ingredients', 'name', 'base', 'saving']
  })],

  render() {
    return (() => {
      switch (this.state.currentPage) {

        case EditableRecipePageType.NAME:
          return <EditableNamePage onNext={this._makePageSwitcher(EditableRecipePageType.INGREDIENTS)} onClose={this.props.onClose} />;

        case EditableRecipePageType.INGREDIENTS:
          return <EditableIngredientsPage previousTitle={`"${ this.state.name }"`} onPrevious={this._makePageSwitcher(EditableRecipePageType.NAME)} onNext={this._makePageSwitcher(EditableRecipePageType.BASE)} onClose={this.props.onClose} />;

        case EditableRecipePageType.BASE:
          let previousTitle = `${ this.state.ingredients.length } ingredient`;
          if (this.state.ingredients.length !== 1) {
            previousTitle += 's';
          }
          return <EditableBaseLiquorPage previousTitle={previousTitle} onPrevious={this._makePageSwitcher(EditableRecipePageType.INGREDIENTS)} onNext={this._makePageSwitcher(EditableRecipePageType.TEXT)} onClose={this.props.onClose} />;

        case EditableRecipePageType.TEXT:
          if (this.state.base.length === 1) {
            previousTitle = `${ definitions.BASE_TITLES_BY_TAG[this.state.base[0]] }-based`;
          } else {
            previousTitle = `${ this.state.base.length } base liquors`;
          }
          return <EditableTextPage previousTitle={previousTitle} onPrevious={this._makePageSwitcher(EditableRecipePageType.BASE)} onNext={this._makePageSwitcher(EditableRecipePageType.PREVIEW)} onClose={this.props.onClose} />;

        case EditableRecipePageType.PREVIEW:
          return <PreviewPage previousTitle='Instructions' onPrevious={this._makePageSwitcher(EditableRecipePageType.TEXT)} onNext={this._finish} onClose={this.props.onClose} recipe={this._constructRecipe()} isSaving={this.state.saving} />;
      }
    })();
  },

  _makePageSwitcher(page) {
    return () => {
      return store.dispatch({
        type: 'set-editable-recipe-page',
        page
      });
    };
  },

  _finish() {
    return store.dispatch(editableRecipeActions.saveRecipe(this._constructRecipe())).then(() => {
      return this.props.onClose();
    });
  },

  _constructRecipe() {
    const editableRecipeState = store.getState().editableRecipe;

    const ingredients = _.map(editableRecipeState.ingredients, ingredient => {
      return _.pick(_.extend({ tag: ingredient.tag }, ingredient.display), _.identity);
    });

    const recipe = _.chain(editableRecipeState).pick('name', 'instructions', 'notes', 'base', 'originalRecipeId').extend({ ingredients, isCustom: true }).pick(_.identity).value();

    return normalization.normalizeRecipe(recipe);
  }
});


