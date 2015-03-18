features
- react router for permalinking to recipes?
- adding recipes

todo
- clean up styling (more variables for sizes, things are in the wrong place, things are duplicated)
- on-scroll behavior is hilariously, wildly inefficient: there has got to be a better way to do this or at least to design around it
- having views hide themselves by knowing which overlay they're in is sketchy
- sticky header based off of headered list
- use URL/source property so people can check out the original recipe
- swiping support for opening/closing overlays
- clean up inconsistent spelling/casing for IBA recipe text

bugs
- the overscroll on the iphone status bar means you can drag it down away from the content of the status bar and it looks dumb
- rotating the app sideways or dragging the wrong thing at the wrong time can wreck the iOS display in Safari (do I care?)
- when showing the page for the first time you get a flash of "nothing to see here" -- perhaps some better zero state while things load?
- autoprefixer isn't adding things it should (like the appearance rule on inputs)
- when overlays are shown, you can still interact with things behind it; pointer-events doesn't seem to be sufficient
- fix up the numerical display on the ingredient group tabs -- too many magic constants
- scrolling on the shopping list doesn't dismiss the search focus (should listen on document, probably)
- would it be possible to use media queries to remove the iPhone spacer header bar thing when Personal Hotspot is on?
- searsching on the shopping list is the same as regular recipes, meaning it includes ingredients you can't see (and might already have, which yields potentially confusing results)

design ideas
- "What ingredient gives me the most bang for my buck?"
  - an inverted shopping cart -- for each ingredient, what are the drinks you could make if you got { just it, other stuff too }?
- "What drinks can I make with {X} in them?"
  - some way to search withiin mixables/all for an ingredient as well as a name
- FTUE -- it's not clear what people should be doing (but how much of this can we just design around?)
- similar drink suggestions based on ingredients?
- a note about glassware (and garnish?) would be a neat addition
- some kind of reset for ingredients would be nice
- buffer space on the bottom of the exandable list for ingredients might make for a nicer expanding-things-near-the-bottom experience
- designing around the sticky header might be nice -- it's crazy inefficient and could potentially drain the battery on a phone (and look dumb in the process)

recipes
- add a validation for:
  - no duplicate recipes (by normalized name)
  - no recipes calling for ingredients that don't exist
- everything is in thirds and is it acceptable to adjust the measurements to not be dumb?
- add:
  - white russian
  - blind russian
- for specialty ingredients like e.g. raspberry simple syrup, consider classifying the ingredient as listed in the recipe under just "raspberry", since cluttering the ingredients page with really rare syrups or bitters or infusions when you could theoretically remake them with the base ingredient seems silly
- merge some ingredients, e.g., egg white + egg yolk should just be "egg" under the hood
