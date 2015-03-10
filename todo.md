features
- react router for permalinking to recipes?
- adding recipes
- swiping between recipes
- bookmarking instead of lists

todo
- clean up styling (more variables for sizes, things are in the wrong place, things are duplicated)
- do animations for overlays and ingredient sections when they're created destroyed (ReactCSSTransitionGroup?)
- make it easier to open all the groups of ingredients
- on-scroll behavior is hilariously, wildly inefficient: there has got to be a better way to do this or at least to design around it
- deployment scripts
  - and pick something better than nohup to run the exectuable

bugs
- gotta use ontouchtap cause the 300ms delay is killing me
- the overscroll on the iphone status bar means you can drag it down away from the content of the status bar and it looks dumb
- rotating the app sideways or dragging the wrong thing at the wrong time can wreck the iOS display in Safari (do I care?)
- when showing the page for the first time you get a flash of "nothing to see here" -- perhaps some better zero state while things load?
- when searching on the iPhone, the search results can appear below the keyboard, forcing you to dismiss it to see them
- autoprefixer isn't adding things it should (like the appearance rule on inputs)

design ideas
- "What ingredient gives me the most bang for my buck?"
  - an inverted shopping cart -- for each ingredient, what are the drinks you could make if you got { just it, other stuff too }?
- "What drinks can I make with {X} in them?"
  - some way to search withiin mixables/all for an ingredient as well as a name
- a note about glassware (and garnish?) would be a neat addition
- some kind of reset for ingredients would be nice
- buffer space on the bottom of the exandable list for ingredients might make for a nicer expanding-things-near-the-bottom experience
- designing around the sticky header might be nice -- it's crazy inefficient and could potentially drain the battery on a phone (and look dumb in the process)
