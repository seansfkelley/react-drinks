import { clone, flatten, sortBy, omit, partial } from 'lodash';
import * as React from 'react';
import * as classNames from 'classnames';
import * as PureRenderMixin from 'react-addons-pure-render-mixin';

import { GroupedIngredients } from '../types';
import { Ingredient } from '../../shared/types';
import List from '../components/List';

import {INGREDIENTS_LIST_ITEM_HEIGHT, INGREDIENTS_LIST_GROUP_HEIGHT_OFFSET } from '../stylingConstants';

interface IngredientGroupHeaderProps {
  title: string;
  selectedCount: number;
  onToggle?: () => void;
}

const IngredientGroupHeader = React.createClass<IngredientGroupHeaderProps, void>({
  displayName: 'IngredientGroupHeader',

  mixins: [PureRenderMixin],

  render() {
    return (
      <List.Header onClick={this.props.onToggle}>
        <span className='text'>{this.props.title}</span>
        {this.props.selectedCount > 0
          ? <span className='count'>{this.props.selectedCount}</span>
          : undefined}
      </List.Header>
    );
  }
});

interface IngredientItemGroupProps {
  title: string;
  isExpanded?: boolean;
}

const IngredientItemGroup = React.createClass<IngredientItemGroupProps, void>({
  displayName: 'IngredientItemGroup',

  mixins: [PureRenderMixin],

  getDefaultProps() {
    return {
      isExpanded: true
    } as any as IngredientItemGroupProps;
  },

  render() {
    const style = this.props.isExpanded
      ? { height: React.Children.count(this.props.children) * INGREDIENTS_LIST_ITEM_HEIGHT + INGREDIENTS_LIST_GROUP_HEIGHT_OFFSET }
      : undefined;

    return (
      <List.ItemGroup className={classNames({ 'collapsed': !this.props.isExpanded })} style={style}>
        {this.props.children}
      </List.ItemGroup>
    );
  }
});

interface IngredientListItemProps {
  isSelected: boolean;
  ingredient: Ingredient;
  toggleTag: (tag: string) => void;
}

const IngredientListItem = React.createClass<IngredientListItemProps, void>({
  displayName: 'IngredientListItem',

  mixins: [PureRenderMixin],

  render() {
    return (
      <List.Item className={classNames({ 'is-selected': this.props.isSelected })} onClick={this._toggleIngredient}>
        <div className='name'>{this.props.ingredient.display}</div>
        <i className='fa fa-check-circle has-ingredient-icon' />
      </List.Item>
    );
  },

  _toggleIngredient() {
    this.props.toggleTag(this.props.ingredient.tag);
  }
});

interface Props {
  groupedIngredients: GroupedIngredients[];
  initialSelectedIngredientTags: { [tag: string]: any };
  onSelectionChange?: (selectedIngredientTags: { [tag: string]: any }) => void;
}

interface State {
  expandedGroupName?: string;
  selectedIngredientTags: string[];
}

export default React.createClass<Props, State>({
  displayName: 'GroupedIngredientList',

  mixins: [PureRenderMixin],

  getInitialState() {
    return {
      expandedGroupName: undefined,
      selectedIngredientTags: clone(this.props.initialSelectedIngredientTags)
    };
  },

  render() {
    const _makeListItem = (i: Ingredient) => (
      <IngredientListItem
        ingredient={i}
        isSelected={this.state.selectedIngredientTags[i.tag] != null}
        toggleTag={this._toggleIngredient}
        key={i.tag}
      />
    );

    const ingredientCount = (this.props as Props).groupedIngredients
      .map(group => group.ingredients.length)
      .reduce((sum, n) => sum + n, 0);

    let listItems: React.ReactNode[];

    if (ingredientCount === 0) {
      listItems = [];
    } else if (ingredientCount < 10) {
      const ingredients = sortBy(flatten((this.props as Props).groupedIngredients.map(group => group.ingredients)), i => i.display);
      const selectedCount = ingredients.filter(i => this.state.selectedIngredientTags[i.tag] != null).length;

      const header = <IngredientGroupHeader
        title={`All Results (${ ingredientCount })`}
        selectedCount={selectedCount}
        key='header-all-results'
      />;

      listItems = [header, ingredients.map(_makeListItem)];
    } else {
      listItems = [];
      for (let { name, ingredients } of this.props.groupedIngredients) {
        const ingredientNodes = [];
        let selectedCount = 0;
        for (let i of ingredients) {
          ingredientNodes.push(_makeListItem(i));
          if (this.state.selectedIngredientTags[i.tag] != null) {
            selectedCount += 1;
          }
        }
        listItems = listItems.concat([
          <IngredientGroupHeader
            title={name}
            selectedCount={selectedCount}
            onToggle={partial(this._toggleGroup, name)}
            key={`header-${ name }`}
          />
        ,
          <IngredientItemGroup
            title={name}
            isExpanded={this.state.expandedGroupName === name}
            key={`group-${ name }`}
          >
            {ingredientNodes}
          </IngredientItemGroup>
        ]);
      }
    }

    return (
      <List
        className={classNames(List.ClassNames.HEADERED, List.ClassNames.COLLAPSIBLE, 'grouped-ingredient-list')}
        emptyText='Nothing matched your search.'
      >
        {listItems}
      </List>
    );
  },

  getSelectedTags() {
    return this.state.selectedIngredientTags;
  },

  _toggleGroup(expandedGroupName: string) {
    if (this.state.expandedGroupName === expandedGroupName) {
      this.setState({ expandedGroupName: null });
    } else {
      this.setState({ expandedGroupName });
    }
  },

  _toggleIngredient(tag: string) {
    let selectedIngredientTags;
    if (this.state.selectedIngredientTags[tag] != null) {
      selectedIngredientTags = omit(this.state.selectedIngredientTags, tag);
    } else {
      selectedIngredientTags = clone(this.state.selectedIngredientTags);
      selectedIngredientTags[tag] = true;
    }
    this.setState({ selectedIngredientTags });
    if (this.props.onSelectionChange) {
      this.props.onSelectionChange(selectedIngredientTags);
    }
  }
});
