import {} from 'lodash';
const React = require('react');
const classnames = require('classnames');
const PureRenderMixin = require('react-addons-pure-render-mixin');

const List = require('../components/List');

const stylingConstants = require('../stylingConstants');

const IngredientGroupHeader = React.createClass({
  displayName: 'IngredientGroupHeader',

  propTypes: {
    title: React.PropTypes.string.isRequired,
    selectedCount: React.PropTypes.number.isRequired,
    onToggle: React.PropTypes.func
  },

  mixins: [PureRenderMixin],

  render() {
    return <List.Header onTouchTap={this.props.onToggle}><span className='text'>{this.props.title}</span>{this.props.selectedCount > 0 ? <span className='count'>{this.props.selectedCount}</span> : undefined}</List.Header>;
  }
});

const IngredientItemGroup = React.createClass({
  displayName: 'IngredientItemGroup',

  propTypes: {
    title: React.PropTypes.string.isRequired,
    isExpanded: React.PropTypes.bool
  },

  mixins: [PureRenderMixin],

  getDefaultProps() {
    return {
      isExpanded: true
    };
  },

  render() {
    let style;
    const groupSize = React.Children.count(this.props.children);
    if (this.props.isExpanded) {
      style = {
        height: groupSize * stylingConstants.INGREDIENTS_LIST_ITEM_HEIGHT + stylingConstants.INGREDIENTS_LIST_GROUP_HEIGHT_OFFSET
      };
    }

    return <List.ItemGroup className={classnames({ 'collapsed': !this.props.isExpanded })} style={style}>{this.props.children}</List.ItemGroup>;
  }
});

const IngredientListItem = React.createClass({
  displayName: 'IngredientListItem',

  propTypes: {
    isSelected: React.PropTypes.bool.isRequired,
    ingredient: React.PropTypes.object.isRequired,
    toggleTag: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  render() {
    let className;
    if (this.props.isSelected) {
      className = 'is-selected';
    }

    return <List.Item className={className} onTouchTap={this._toggleIngredient}><div className='name'>{this.props.ingredient.display}</div><i className='fa fa-check-circle has-ingredient-icon' /></List.Item>;
  },

  _toggleIngredient() {
    return this.props.toggleTag(this.props.ingredient.tag);
  }
});

const GroupedIngredientList = React.createClass({
  displayName: 'GroupedIngredientList',

  propTypes: {
    groupedIngredients: React.PropTypes.array,
    initialSelectedIngredientTags: React.PropTypes.object,
    onSelectionChange: React.PropTypes.func
  },

  mixins: [PureRenderMixin],

  getInitialState() {
    return {
      expandedGroupName: null,
      selectedIngredientTags: _.clone(this.props.initialSelectedIngredientTags)
    };
  },

  render() {
    let ingredients, listNodes, selectedCount;
    const ingredientCount = _.chain(this.props.groupedIngredients).pluck('ingredients').pluck('length').reduce((sum, n) => sum + n, 0).value();

    const _makeListItem = i => {
      return <IngredientListItem ingredient={i} isSelected={this.state.selectedIngredientTags[i.tag] != null} toggleTag={this._toggleIngredient} key={i.tag} />;
    };

    if (ingredientCount === 0) {
      listNodes = [];
    } else if (ingredientCount < 10) {
      ingredients = _.chain(this.props.groupedIngredients).pluck('ingredients').flatten().sortBy('displayName').value();

      selectedCount = _.filter(ingredients, i => this.state.selectedIngredientTags[i.tag] != null).length;

      const header = <IngredientGroupHeader title={`All Results (${ ingredientCount })`} selectedCount={selectedCount} key='header-all-results' />;

      listNodes = [header, _.map(ingredients, _makeListItem)];
    } else {
      let name;
      listNodes = [];
      for ({ name, ingredients } of this.props.groupedIngredients) {
        const ingredientNodes = [];
        selectedCount = 0;
        for (let i of ingredients) {
          ingredientNodes.push(_makeListItem(i));
          if (this.state.selectedIngredientTags[i.tag] != null) {
            selectedCount += 1;
          }
        }
        listNodes.push([<IngredientGroupHeader title={name} selectedCount={selectedCount} onToggle={_.partial(this._toggleGroup, name)} key={`header-${ name }`} />, <IngredientItemGroup title={name} isExpanded={this.state.expandedGroupName === name} key={`group-${ name }`}>{ingredientNodes}</IngredientItemGroup>]);
      }
    }

    return <List className={classnames(List.ClassNames.HEADERED, List.ClassNames.COLLAPSIBLE, 'grouped-ingredient-list')} emptyText='Nothing matched your search.'>{listNodes}</List>;
  },

  getSelectedTags() {
    return this.state.selectedIngredientTags;
  },

  _toggleGroup(expandedGroupName) {
    if (this.state.expandedGroupName === expandedGroupName) {
      return this.setState({ expandedGroupName: null });
    } else {
      return this.setState({ expandedGroupName });
    }
  },

  _toggleIngredient(tag) {
    // It is VERY IMPORTANT that these create a new instance: this is how PureRenderMixin guarantees correctness.
    let selectedIngredientTags;
    if (this.state.selectedIngredientTags[tag] != null) {
      selectedIngredientTags = _.omit(this.state.selectedIngredientTags, tag);
    } else {
      selectedIngredientTags = _.clone(this.state.selectedIngredientTags);
      selectedIngredientTags[tag] = true;
    }
    this.setState({ selectedIngredientTags });
    return __guardMethod__(this.props, 'onSelectionChange', o => o.onSelectionChange(selectedIngredientTags));
  }
});

module.exports = GroupedIngredientList;

function __guardMethod__(obj, methodName, transform) {
  if (typeof obj !== 'undefined' && obj !== null && typeof obj[methodName] === 'function') {
    return transform(obj, methodName);
  } else {
    return undefined;
  }
}
