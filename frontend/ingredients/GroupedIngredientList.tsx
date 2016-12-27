import { clone, flatten, sortBy, omit } from 'lodash';
import * as React from 'react';
import * as classNames from 'classnames';

import { GroupedIngredients } from '../types';
import { Ingredient } from '../../shared/types';
import { List, ListHeader, ListItem, ListItemGroup, ListClassNames } from '../components/List';

import { INGREDIENTS_LIST_ITEM_HEIGHT, INGREDIENTS_LIST_GROUP_HEIGHT_OFFSET } from '../stylingConstants';

interface IngredientGroupHeaderProps {
  title: string;
  selectedCount: number;
  onToggle?: () => void;
}

const IngredientGroupHeader: React.StatelessComponent<IngredientGroupHeaderProps> = (props) => (
  <ListHeader onClick={props.onToggle}>
    <span className='text'>{props.title}</span>
    {props.selectedCount > 0
      ? <span className='count'>{props.selectedCount}</span>
      : undefined}
  </ListHeader>
);

interface IngredientItemGroupProps {
  title: string;
  isExpanded?: boolean;
}

const IngredientItemGroup: React.StatelessComponent<IngredientItemGroupProps> = (props) => {
  const isExpanded = !!props.isExpanded;

  const style = isExpanded
    ? { height: React.Children.count(props.children) * INGREDIENTS_LIST_ITEM_HEIGHT + INGREDIENTS_LIST_GROUP_HEIGHT_OFFSET }
    : undefined;

  return (
    <ListItemGroup className={classNames({ 'collapsed': !isExpanded })} style={style}>
      {props.children}
    </ListItemGroup>
  );
}

interface IngredientListItemProps {
  isSelected: boolean;
  ingredient: Ingredient;
  toggleTag: (tag: string) => void;
}

const IngredientListItem: React.StatelessComponent<IngredientListItemProps> = (props) => (
  <ListItem
    className={classNames({ 'is-selected': props.isSelected })}
    onClick={() => props.toggleTag(props.ingredient.tag)}
  >
    <div className='name'>{props.ingredient.display}</div>
    <i className='fa fa-check-circle has-ingredient-icon' />
  </ListItem>
);

interface Props {
  groupedIngredients: GroupedIngredients[];
  selectedIngredientTags: { [tag: string]: any };
  onSelectionChange: (selectedIngredientTags: { [tag: string]: any }) => void;
}

interface State {
  expandedGroupName?: string;
}

export default class GroupedIngredientList extends React.PureComponent<Props, State> {
  state: State = {};

  render() {
    const ingredientCount = this.props.groupedIngredients
      .map(group => group.ingredients.length)
      .reduce((sum, n) => sum + n, 0);

    let listItems: React.ReactNode[];

    if (ingredientCount === 0) {
      listItems = [];
    } else if (ingredientCount < 10) {
      const ingredients = sortBy(flatten(this.props.groupedIngredients.map(group => group.ingredients)), i => i.display);
      const selectedCount = ingredients.filter(i => this.props.selectedIngredientTags[i.tag] != null).length;

      const header = (
        <IngredientGroupHeader
          title={`All Results (${ ingredientCount })`}
          selectedCount={selectedCount}
          key='header-all-results'
        />
      );

      listItems = [header, ingredients.map(this._makeListItem)];
    } else {
      listItems = [];
      for (let { name, ingredients } of this.props.groupedIngredients) {
        const ingredientNodes = [];
        let selectedCount = 0;
        for (let i of ingredients) {
          ingredientNodes.push(this._makeListItem(i));
          if (this.props.selectedIngredientTags[i.tag] != null) {
            selectedCount += 1;
          }
        }
        listItems = listItems.concat([
          <IngredientGroupHeader
            title={name}
            selectedCount={selectedCount}
            onToggle={() => this._toggleGroup(name)}
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
        className={classNames(ListClassNames.HEADERED, ListClassNames.COLLAPSIBLE, 'grouped-ingredient-list')}
        emptyText='Nothing matched your search.'
      >
        {listItems}
      </List>
    );
  }

  private _makeListItem = (i: Ingredient) => {
    return (
      <IngredientListItem
        ingredient={i}
        isSelected={this.props.selectedIngredientTags[i.tag] != null}
        toggleTag={this._toggleIngredient}
        key={i.tag}
      />
    );
  };

  private _toggleGroup = (expandedGroupName: string) => {
    if (this.state.expandedGroupName === expandedGroupName) {
      this.setState({ expandedGroupName: undefined });
    } else {
      this.setState({ expandedGroupName });
    }
  };

  private _toggleIngredient = (tag: string) => {
    let selectedIngredientTags;
    if (this.props.selectedIngredientTags[tag] != null) {
      selectedIngredientTags = omit(this.props.selectedIngredientTags, tag);
    } else {
      selectedIngredientTags = clone(this.props.selectedIngredientTags);
      selectedIngredientTags[tag] = true;
    }
    this.props.onSelectionChange(selectedIngredientTags);
  };
};
