import { Ingredient } from '../../../shared/types';
import { GroupedIngredients } from '../../types';
import { memoize } from './memoize';

export function filteredGroupedIngredients({ groupedIngredients, searchTerm }: { groupedIngredients: GroupedIngredients[], searchTerm?: string }) {
  if (searchTerm == null) {
    searchTerm = '';
  }
  searchTerm = searchTerm.trim();

  if (searchTerm === '') {
    return groupedIngredients;
  } else {
    searchTerm = searchTerm.toLowerCase();

    const filterBySearchTerm = (i: Ingredient) => {
      for (let term of i.searchable) {
        if (term.indexOf(searchTerm!) !== -1) {
          return true;
        }
      }
      return false;
    };

    return groupedIngredients
      .map(({ name, ingredients }) => ({
        name,
        ingredients: ingredients.filter(filterBySearchTerm)
      }))
      .filter(({ ingredients }) => ingredients.length > 0);
  }
};

export const memoized = memoize(filteredGroupedIngredients);
