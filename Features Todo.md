### Code Quality
- having views hide themselves by knowing which overlay they're in is sketchy
- dark-on-light and light-on-dark theme classes?

### Recipes
- garnish section in ingredients
- clean up inconsistent spelling/casing for IBA recipe text
- add a validation for:
  - no duplicate recipes (by normalized name)
  - no recipes calling for ingredients that don't exist
- everything is in thirds so is it acceptable to adjust the measurements to not be dumb?

### Ingredients
- merge some ingredients, e.g., egg white + egg yolk should just be "egg" under the hood
- for specialty ingredients like e.g. raspberry simple syrup, consider classifying the ingredient as listed in the recipe under just "raspberry", since cluttering the ingredients page with really rare syrups or bitters or infusions when you could theoretically remake them with the base ingredient seems silly
- searching for an ingredient should bring up things based on their generics too
- change recipes to infer display from ingredient if they don't want to specify something more specific

### Adding/Editing Recipes
- Fix up styling
  - Animate additions/removals of deletable ingredients
- Drag-to-reorder
- Figure out how to signal that an empty ingredient won't be used or whatever.

### Frontend Perf
- When toggling ingredients, a lot of shit goes on in the background. The entire search result index is rebuilt, which triggers all the views to rerender even though they're in the background.
  - Don't re-render things even though they're in the background: is there a good way to destroy the DOM in teh background while the overlay is up?
  - Incremental updates: when a single ingredient updates, we should be able to basically compute the diff that ingredient causes and apply that to the index, rather than recompute the whole world.
  - More targeted change events: not sure if this is a significant performance hit, but having everything fire just a change event is easy to use but it means that anything on the store to change will cause everything to fire and everything to rebuild. PureRenderMixin might help with this, though there are instances where state is mutated rather than updated and replaced (e.g. selectedIngredientTags).
  - Push listening to events farther down the view hierarchy: there might be some cases where we're rebuilding a large section of the view just because we pass something down from the top level. I thought this was selectedIngredientTags but it doesn't appear to be.
