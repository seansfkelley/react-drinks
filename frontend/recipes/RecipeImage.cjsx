_                   = require 'lodash'
React               = require 'react/addons'
{ PureRenderMixin } = React.addons

GlassType = {
  ROCKS : 'roc'
}

ORDERED_LAYERS = [
  # BACKGROUND
  'gbk'  # glass background

  # ICE
  'icr'  # crushed ice
  'icrt' # ??? some kind of ice probably, but doesn't appear in the UI
  'icu'  # ice cubes
  'ihu'  # ice huge

  # COLOR OF DRINK
  # ???

  # FOREGROUND
  'gfg'  # glass foreground

  # CITRUS
  'lep'  # lemon peel
  'les'  # lemon slice
  'let'  # lemon twist
  'lip'  # lime peel
  'lis'  # lime slice
  'lit'  # lime twist
  'orp'  # orange peel
  'ors'  # orange slice
  'ort'  # orange twist

  # GARNISH
  'aps'  # apple slice
  'cel'  # celery
  'che'  # cherry
  'cuc'  # cucumber
  'lb'   # ??? something in the shape of the glass, maybe the mask for the color?
  'lt'   # ??? something in the shape of the top of the glass
  'olv'  # olive
  'pine' # pineapple
  'strawb' # strawberry

  # EXTRAS
  'mint' # mint
  'str'  # straw
  'salt' # salted rim
  'umb'  # umbrella
  'whip' # whipped cream

  'vi'   # list image
]


RecipeImage = React.createClass {
  displayName : 'RecipeImage'

  mixins : [ PureRenderMixin ]

  propTypes : {}

  render : ->
    testLayers = _.chain ORDERED_LAYERS
      .sample(4)
      .push 'gbk'
      .push 'gfg'
      .uniq()
      .sortBy (i) -> _.indexOf ORDERED_LAYERS, i
      .map (i) -> "/assets/img/drinks-parts/roc-#{i}_420@2x.png"
      .value()
    <div className='recipe-image'>
      {_.map testLayers, (l) -> <img src={l} className='layer'/>}
    </div>
}

module.exports = RecipeImage
