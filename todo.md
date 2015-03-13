features
- react router for permalinking to recipes?
- adding recipes

todo
- clean up styling (more variables for sizes, things are in the wrong place, things are duplicated)
- do animations for overlays and ingredient sections when they're created destroyed (ReactCSSTransitionGroup?)
- make it easier to open all the groups of ingredients
- on-scroll behavior is hilariously, wildly inefficient: there has got to be a better way to do this or at least to design around it
- having views hide themselves by knowing which overlay they're in is sketchy
- sticky header based off of headered list
- collapsible list based off of headered list
- swipable list may not be cleaning up nodes after it's hidden

bugs
- the overscroll on the iphone status bar means you can drag it down away from the content of the status bar and it looks dumb
- rotating the app sideways or dragging the wrong thing at the wrong time can wreck the iOS display in Safari (do I care?)
- when showing the page for the first time you get a flash of "nothing to see here" -- perhaps some better zero state while things load?
- autoprefixer isn't adding things it should (like the appearance rule on inputs)
- tapping on the search bar selects them immediately deselects the input
- if the search input on recipes is left open when you open ingredients (should it be?), you can open ingredients, then close it and it will also highlight the search bar (perhaps something to do with pointer-events being turned off when the class changes? prevent default?)
- when the pushover view is shown on iOS you can scroll the page back over and see the hidden view; also pointer events still work on it for some reason

design ideas
- "What ingredient gives me the most bang for my buck?"
  - an inverted shopping cart -- for each ingredient, what are the drinks you could make if you got { just it, other stuff too }?
- "What drinks can I make with {X} in them?"
  - some way to search withiin mixables/all for an ingredient as well as a name
- a note about glassware (and garnish?) would be a neat addition
- some kind of reset for ingredients would be nice
- buffer space on the bottom of the exandable list for ingredients might make for a nicer expanding-things-near-the-bottom experience
- designing around the sticky header might be nice -- it's crazy inefficient and could potentially drain the battery on a phone (and look dumb in the process)
