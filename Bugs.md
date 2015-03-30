- the overscroll on the iphone status bar means you can drag it down away from the content of the status bar and it looks dumb
- rotating the app sideways or dragging the wrong thing at the wrong time can wreck the iOS display in Safari (do I care?)
- when showing the page for the first time you get a flash of "nothing to see here" -- perhaps some better zero state while things load?
- on-scroll behavior is hilariously, wildly inefficient: there has got to be a better way to do this or at least to design around it
- autoprefixer isn't adding things it should (like the appearance rule on inputs)
- when overlays are shown, you can still interact with things behind it; pointer-events doesn't seem to be sufficient
- scrolling on the shopping list doesn't dismiss the search focus (should listen on document, probably)
- would it be possible to use media queries to remove the iPhone spacer header bar thing when Personal Hotspot is on?
- searching on the shopping list is the same as regular recipes, meaning it includes ingredients you can't see (and might already have, which yields potentially confusing results)
- buffer space on the bottom of the exandable list for ingredients might make for a nicer expanding-things-near-the-bottom experience

editable recipes
- on iOS, tabbing over using the keyboard buttons doesn't work nicely cause the other inputs are hidden
- on iOS, commiting the tag doesn't close the dropdown for whatever reason
- on iOS, the dropdown is under the textarea (wtf?)
- on iOS, the keyboard jumps in and out as things are focused and blurred and it's really annoying
- Select no longer deselects after one thing has been selected

