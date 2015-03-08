features
- react router for permalinking to recipes?
- adding recipes
- swiping between recipes

todo
- clean up styling (more variables for sizes, things are in the wrong place)
- do animations for overlays and ingredient sections when they're created destroyed (ReactCSSTransitionGroup?)

bugs
- since modals reuse the same dom element, doing one and then the other really fast (i.e. before the 1s cleanup) makes it so they don't come in with a transition
- something on the ingredients page isn't assigning a key and is causing problems
