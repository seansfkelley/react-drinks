- the overscroll on the iphone status bar means you can drag it down away from the content of the status bar and it looks dumb
- when showing the page for the first time you get a flash of "nothing to see here" -- perhaps some better zero state while things load?
- autoprefixer isn't adding things it should (like the appearance rule on inputs)
- when overlays are shown, you can still interact with things behind it; pointer-events doesn't seem to be sufficient
- would it be possible to use media queries to remove the iPhone spacer header bar thing when Personal Hotspot is on?
- buffer space on the bottom of the exandable list for ingredients might make for a nicer expanding-things-near-the-bottom experience
- can tab over to search bars that are currently obscured, but tabIndex=-1 doesn't seem to prevent it

- favorites should incorporate ingredients you have somehow
- fixedheaderfooter shouldn't take headers and footers as props: they should just be wrapper components
