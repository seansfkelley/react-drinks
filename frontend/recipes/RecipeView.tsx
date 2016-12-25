import {} from 'lodash';
import * as React from 'react';
const PureRenderMixin = require('react-addons-pure-render-mixin');
const classnames = require('classnames');

const utils = require('../utils');
const definitions = require('../../shared/definitions');

const ReduxMixin = require('../mixins/ReduxMixin');

const TitleBar = require('../components/TitleBar');

const MeasuredIngredient = require('./MeasuredIngredient');

const IS_IPHONE_IOS_8 = window.navigator.userAgent.indexOf('iPhone OS 8') !== -1;

const IngredientCategory = {
  MISSING: 'missing',
  SUBSTITUTE: 'substitute',
  AVAILABLE: 'available'
};

const IconButton = ({ icon, text, onClick }) => <div className='icon-button' onClick={onClick}><i className={classnames('fa', icon)} /><div className='label'>{text}</div></div>;

IconButton.propTypes = {
  icon: React.PropTypes.string,
  text: React.PropTypes.string,
  onClick: React.PropTypes.func
};

const RecipeView = React.createClass({
  displayName: 'RecipeView',

  mixins: [PureRenderMixin],

  propTypes: {
    recipe: React.PropTypes.object.isRequired,
    ingredientSplits: React.PropTypes.object,
    ingredientsByTag: React.PropTypes.object,
    onClose: React.PropTypes.func,
    onFavorite: React.PropTypes.func,
    onEdit: React.PropTypes.func,
    isFavorited: React.PropTypes.bool,
    isShareable: React.PropTypes.bool
  },

  getDefaultProps() {
    return {
      isShareable: false
    };
  },

  render() {
    let header, ingredientNodes, recipeNotes, recipeUrl;
    if (this.props.ingredientSplits != null) {
      ingredientNodes = _.chain(IngredientCategory).invert().mapValues((_, key) => this.props.ingredientSplits[key])
      // TODO: The order these sections end up in is arbitrary; we should enforce it.
      .map(this._renderCategory).flatten().value();
    } else {
      ingredientNodes = _.map(this.props.recipe.ingredients, i =>
      // This fucked-up key is because sometimes, the same tag will appear twice (e.g. Penicillin's two scotches).
      <MeasuredIngredient {...Object.assign({}, i, { "key": `${ i.tag } ${ i.displayIngredient }` })} />);
    }

    if (this.props.recipe.notes != null) {
      recipeNotes = <div className='recipe-notes'><div className='text'>{utils.fractionify(this.props.recipe.notes)}</div></div>;
    }

    if (this.props.recipe.source != null && this.props.recipe.url != null) {
      recipeUrl = <a className='recipe-url' href={this.props.recipe.url} target='_blank'><span className='lead-in'>source:</span>{this.props.recipe.source}<i className='fa fa-external-link' /></a>;
    }

    const instructionLines = _.chain(this.props.recipe.instructions.split('\n')).compact().map((l, i) => <li className='text-line' key={i}>{utils.fractionify(l)}</li>).value();
    const recipeInstructions = <ol className='recipe-instructions'>{instructionLines}</ol>;

    if (this.props.onClose != null) {
      header = <TitleBar className='fixed-header' rightIcon='fa-times' rightIconOnTouchTap={this.props.onClose}>{this.props.recipe.name}</TitleBar>;
    } else {
      header = <TitleBar className='fixed-header'>{this.props.recipe.name}</TitleBar>;
    }

    const footerButtons = [];

    if (this.props.onEdit) {
      footerButtons.push(<IconButton key='edit' icon='fa-pencil-square-o' text='Edit' onClick={this._edit} />);
    }
    if (this.props.isShareable) {
      footerButtons.push(<IconButton key='share' icon='fa-share-square-o' text='Share' onClick={this._share} />);
    }
    if (this.props.onFavorite) {
      footerButtons.push(<IconButton key='favorite' icon={classnames({ 'fa-star': this.props.isFavorited, 'fa-star-o': !this.props.isFavorited })} text='Favorite' onClick={this._favorite} />);
    }

    return <div className='recipe-view fixed-header-footer'>{header}<div className='recipe-description fixed-content-pane'><div className='recipe-ingredients'>{ingredientNodes}</div>{recipeInstructions}{recipeNotes}{recipeUrl}</div>{footerButtons.length ? <div className='fixed-footer'>{footerButtons}</div> : undefined}</div>;
  },

  _edit() {
    return this.props.onEdit(this.props.recipe);
  },

  _share() {
    return window.open(`sms:&body=${ this.props.recipe.name } ${ definitions.BASE_URL }/recipe/${ this.props.recipe.recipeId }`);
  },

  _favorite() {
    return this.props.onFavorite(this.props.recipe, !this.props.isFavorited);
  },

  _renderCategory(measuredIngredients, category) {
    if (measuredIngredients.length === 0) {
      return [];
    } else {
      if (category === IngredientCategory.SUBSTITUTE) {
        measuredIngredients = _.map(measuredIngredients, i => _.defaults({
          isSubstituted: true,
          displaySubstitutes: i.have
        }, i.need));
      } else if (category === IngredientCategory.MISSING) {
        measuredIngredients = _.map(measuredIngredients, i => {
          return _.defaults({
            isMissing: true,
            difficulty: this.props.ingredientsByTag[i.tag].difficulty
          }, i);
        });
      }

      return _.map(measuredIngredients, i => <MeasuredIngredient {...Object.assign({}, i, { "key": `${ i.tag } ${ i.displayIngredient }` })} />);
    }
  }
});

module.exports = RecipeView;
