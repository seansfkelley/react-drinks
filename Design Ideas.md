### "What ingredient gives me the most bang for my buck?"

An inverted shopping cart, of sorts. For each ingredient, what are the drinks you could make if you got it (or possibly, got it and other stuff too)?

### First-Time User Experience

There's really no hand-holding at all, even though it's a fundamentally simple app. A couple specific problems:

- People don't know if they're the target audience or who the target audience is.
  - This is exacerbated when ingredients are subbed without specifying what to sub them with, or when ingredients are named something non-obvious (like "Domaine de Canton" rather than "ginger liqueur").
  - The "mixable" part of the list is not obvious. It takes a little bit for people to notice that they're only looking at drinks they can't make but are being suggested. Not sure if this is because the behavior just doesn't make sense ("why would I want to see this?") or just because it's unusual.
  - People are intimidated by things like the four different kinds of rum.
- The ingredients button isn't obviously a button, so even with text that mention they should start with ingredients people get stuck for a bit.
- The checkmark is totally not obvious and I don't think anyone has ever hit it by themselves. They don't know to look for it when they want to see only things they can mix.

### Explain substitutions and missing ingredients better

People skim, and they miss the fact that they can't actually make a particular drink (at least, they do at first). Making this more obvious (by having to turn it on, or color/size/text changes) could help keep people from mentally investing in something they can't do.

Relatedly, when people figure out that a drink is mixable because of "substitutions", they would like to know what said substitutions are (indeed, I sometimes forget some of the rarer ones like hazulnut liqueur or whatever).

### Reading more about ingredients, or "What is 'amaretto'?

Related again to substitutions, but also in general. There are so many ingredients that it's overwhelming if you don't know what you're doing. Potential ideas to fix this:

- Write up a short description of what a drink is, suitable for putting in a short popup or something.
- Tapping an ingredient in a recipe view could bring it up.
- Tapping some kind of "tell me more" button in the ingredients pane could bring it up.

### Adding recipes

This one's a doozy. The backing data for recipes (and even ingredients) is pretty complex and rich, which is how I'm able to do things like substitutions and smart-ish search.

I wanted to have an interface that looks like the interface for reading recipes, but aside from the fact that the text is pretty small there (and therefore touch targets are small), there's a lot of strict validation (amounts can only be numerical) and data that is not usually surfaced that must be entered (that while it says "Old Tom gin", you also need to specify that this is, indeed "gin", since the display text is only for display -- that distinction is not obvious).

### Misc random ides

- suggest similar drinks based on ingredients
- including a note about glassware somewhere could help the flavor of the app (and be neat facts on the side)
- would a reset button to clear ingredients be at all useful?
- cocktail tips for nonobvious advice
- swiping support for opening/closing overlays?
- include some kind of clickable display for the source (and URL) for any recipes that have it
- when searching for an ingredient using an alternate name (e.g. Baileys instead of Irish Cream), highlight what the matching term is (to show the user that the result of Irish Cream is, in fact, Baileys)
