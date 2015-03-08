features
- react router for permalinking to recipes?
- adding recipes
- swiping between recipes
- icon for home screen, image for startup

todo
- clean up styling (more variables for sizes, things are in the wrong place, things are duplicated)
- do animations for overlays and ingredient sections when they're created destroyed (ReactCSSTransitionGroup?)
- turn of autocorrect/autofill for search bars

bugs
- since modals reuse the same dom element, doing one and then the other really fast (i.e. before the 1s cleanup) makes it so they don't come in with a transition
- gotta use ontouchtap cause the 300ms delay is killing me
