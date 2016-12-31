import { Ingredient } from '../../../shared/types';
import { GroupedItems } from '../../types';

export function filteredGroupedIngredients({ groupedIngredients, searchTerm }: { groupedIngredients: GroupedItems<Ingredient>[], searchTerm?: string }) {
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
      .map(({ groupName, items }) => ({
        groupName,
        items: items.filter(filterBySearchTerm)
      }))
      .filter(({ items }) => items.length > 0);
  }
};
