### Code Quality
- having views hide themselves by knowing which overlay they're in is sketchy
- dark-on-light and light-on-dark theme classes?
- recipesearch should share ingredient-for-tag from stores.coffee

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
- Validate:
  - Ingredients, before adding them to "deletable"
- Tapping a suggestion in the them autocomplete unfocuses then refocuses the key element and causes keyboard jitter
- Flag which recipes are custom so we can delete them
