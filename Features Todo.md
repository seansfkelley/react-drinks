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

### Adding Recipes
- Actually add the recipe to the index
- Fix up styling
  - Select height/spacing is all off
  - Select doesn't discolor itself when it's disabled
  - Disabled inputs grey way out on iOS, which is kind of nice but is inconsistent and may be confusing since you can actually click it
  - What kind of text overflow to do when you shrink elements horizontally?
  - Dropdown is underneath textarea on iOS
  - The editable ingredient is too wide bu overflowe is shitty and doesn't work like you expect
  - Animate additions/removals of deletable ingredients
- Validate:
  - Ingredients, before adding them to "deletable"
  - Recipe, before allowing it to be savable
- Fix up random styling issues with Select
- Focus elements when appropriate
  - After you hit the chevron to pick the next
  - When you tap on once to go back
- Bug where at least on iOS it always selects the first thing from the dropdown even if it's not visible (i.e. Absinthe)
