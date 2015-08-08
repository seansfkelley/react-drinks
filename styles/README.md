With two minor exceptions, all changes were to `/styles`:

- Adjusted `gulpfile.coffee` to only process `index.styl` (while still watching all `.styl` files for changes).
- `MeasuredIngredient.cjsx`: moved substitution text inside `.ingredient` span

#### Structure

Organized the styles by scope/function:

- `_dependencies/` — variables, mixins (things that need to load first)
- `app/` — defaults/resets + the underlying structure
- `components/` — reusable components (except those that seemed more structural)
- `views/` — view styles

Added an `index.styl`, allowing Stylus to control concatenation and `@import` order.


#### Improvements

- Solved `.fixed-header-footer` issue + removed need for relative containers
- Made iOS status-bar background `.*-view`-dependent/animatable
- Figured out a way to make `.base-liquor-selector` arrow transparent
- Reworked `.measured-ingredient` to have equal-width columns wherever possible
- About 30-40% less code


#### Stylus notes

I've grown to appreciate Stylus' succinctness, but full minimalist mode is really hard to scan, even with syntax highlighting. At first glance, which strings are variables, properties, values?

    transition opacity transition-duration

I added colons and `$` for variables:

    transition: opacity $transition-duration

As a plus, `$variables` are syntax-highlight/auto-completable (at least in Atom).

##### Color Variables

Definitely on board with color variables (though there seem to be [two](http://thesassway.com/beginner/variable-naming), [distinctly opposing](http://davidwalsh.name/sass-color-variables-dont-suck) schools of thought on how to name them).

I'm just not sure they make sense for tints of a single hue (like gray). Especially when you end up with things like `$grey10` for white, or the silliness of `darken($grey7, 5%)`. So for the moment I'm using straight hex codes/hsl/rgb.

#### TODO

There are various standard `TODO` thoughts littered throughout. In addition,  any `REMOVE` notes means that I believe the named element can be safely removed, and `RENAME` notes are typically semantic suggestions.

Other miscellaneous thoughts:
- Some of the `components/` are only used in their original context and the tutorial. It might make sense, from an organizational standpoint, to leave them in their `.view` context and make the necessary tutorial styles global with the Stylus `/` root syntax. For the moment I've left them factored, in parallel with their `CoffeeScript` counterparts.
