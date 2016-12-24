const _               = require('lodash');
const React           = require('react');
const PureRenderMixin = require('react-addons-pure-render-mixin');
const classnames      = require('classnames');

const utils       = require('../utils');
const definitions = require('../../shared/definitions');

const ReduxMixin = require('../mixins/ReduxMixin');

const TitleBar = require('../components/TitleBar');

const MeasuredIngredient = require('./MeasuredIngredient');

const IS_IPHONE_IOS_8 = window.navigator.userAgent.indexOf('iPhone OS 8') !== -1;

const IngredientCategory = {
  MISSING    : 'missing',
  SUBSTITUTE : 'substitute',
  AVAILABLE  : 'available'
};

const IconButton = ({ icon, text, onTouchTap }) =>
  React.createElement("div", {"className": 'icon-button', "onTouchTap": (onTouchTap)},
    React.createElement("i", {"className": (classnames('fa', icon))}),
    React.createElement("div", {"className": 'label'}, (text))
  )
;

IconButton.propTypes = {
  icon       : React.PropTypes.string,
  text       : React.PropTypes.string,
  onTouchTap : React.PropTypes.func
};

const RecipeView = React.createClass({
  displayName : 'RecipeView',

  mixins : [ PureRenderMixin ],

  propTypes : {
    recipe           : React.PropTypes.object.isRequired,
    ingredientSplits : React.PropTypes.object,
    ingredientsByTag : React.PropTypes.object,
    onClose          : React.PropTypes.func,
    onFavorite       : React.PropTypes.func,
    onEdit           : React.PropTypes.func,
    isFavorited      : React.PropTypes.bool,
    isShareable      : React.PropTypes.bool
  },

  getDefaultProps() {
    return {
      isShareable : false
    };
  },

  render() {
    let header, ingredientNodes, recipeNotes, recipeUrl;
    if (this.props.ingredientSplits != null) {
      ingredientNodes = _.chain(IngredientCategory)
        .invert()
        .mapValues((_, key) => this.props.ingredientSplits[key])
        // TODO: The order these sections end up in is arbitrary; we should enforce it.
        .map(this._renderCategory)
        .flatten()
        .value();
    } else {
      ingredientNodes = _.map(this.props.recipe.ingredients, i =>
        // This fucked-up key is because sometimes, the same tag will appear twice (e.g. Penicillin's two scotches).
        React.createElement(MeasuredIngredient, Object.assign({},  i, {"key": (`${i.tag} ${i.displayIngredient}`)}))
      );
    }

    if (this.props.recipe.notes != null) {
      recipeNotes =
        React.createElement("div", {"className": 'recipe-notes'},
          React.createElement("div", {"className": 'text'},
            (utils.fractionify(this.props.recipe.notes))
          )
        );
    }

    if ((this.props.recipe.source != null) && (this.props.recipe.url != null)) {
      recipeUrl = React.createElement("a", {"className": 'recipe-url', "href": (this.props.recipe.url), "target": '_blank'},
        React.createElement("span", {"className": 'lead-in'}, "source:"),
        (this.props.recipe.source),
        React.createElement("i", {"className": 'fa fa-external-link'})
      );
    }

    const instructionLines = _.chain(this.props.recipe.instructions.split('\n'))
      .compact()
      .map((l, i) => React.createElement("li", {"className": 'text-line', "key": (i)}, (utils.fractionify(l))))
      .value();
    const recipeInstructions = React.createElement("ol", {"className": 'recipe-instructions'}, (instructionLines));

    if (this.props.onClose != null) {
      header = React.createElement(TitleBar, {"className": 'fixed-header', "rightIcon": 'fa-times', "rightIconOnTouchTap": (this.props.onClose)},
        (this.props.recipe.name)
      );
    } else {
      header = React.createElement(TitleBar, {"className": 'fixed-header'}, (this.props.recipe.name));
    }

    const footerButtons = [];

    if (this.props.onEdit) {
      footerButtons.push(React.createElement(IconButton, { 
        "key": 'edit',  
        "icon": 'fa-pencil-square-o',  
        "text": 'Edit',  
        "onTouchTap": (this._edit)
      })
      );
    }
    if (this.props.isShareable) {
      footerButtons.push(React.createElement(IconButton, { 
        "key": 'share',  
        "icon": 'fa-share-square-o',  
        "text": 'Share',  
        "onTouchTap": (this._share)
      })
      );
    }
    if (this.props.onFavorite) {
      footerButtons.push(React.createElement(IconButton, { 
        "key": 'favorite',  
        "icon": (classnames({ 'fa-star' : this.props.isFavorited, 'fa-star-o' : !this.props.isFavorited })),  
        "text": 'Favorite',  
        "onTouchTap": (this._favorite)
      })
      );
    }

    return React.createElement("div", {"className": 'recipe-view fixed-header-footer'},
      (header),
      React.createElement("div", {"className": 'recipe-description fixed-content-pane'},
        React.createElement("div", {"className": 'recipe-ingredients'},
          (ingredientNodes)
        ),
        (recipeInstructions),
        (recipeNotes),
        (recipeUrl)
      ),
      (footerButtons.length ? React.createElement("div", {"className": 'fixed-footer'}, (footerButtons)) : undefined)
    );
  },

  _edit() {
    return this.props.onEdit(this.props.recipe);
  },

  _share() {
    return window.open(`sms:&body=${this.props.recipe.name} ${definitions.BASE_URL}/recipe/${this.props.recipe.recipeId}`);
  },

  _favorite() {
    return this.props.onFavorite(this.props.recipe, !this.props.isFavorited);
  },

  _renderCategory(measuredIngredients, category) {
    if (measuredIngredients.length === 0) {
      return [];
    } else {
      if (category === IngredientCategory.SUBSTITUTE) {
        measuredIngredients = _.map(measuredIngredients, i =>
          _.defaults({
            isSubstituted      : true,
            displaySubstitutes : i.have
          }, i.need)
        );
      } else if (category === IngredientCategory.MISSING) {
        measuredIngredients = _.map(measuredIngredients, i => {
          return _.defaults({
            isMissing  : true,
            difficulty : this.props.ingredientsByTag[i.tag].difficulty
          }, i);
        }
        );
      }

      return _.map(measuredIngredients, i => React.createElement(MeasuredIngredient, Object.assign({},  i, {"key": (`${i.tag} ${i.displayIngredient}`)})));
    }
  }
});

module.exports = RecipeView;
