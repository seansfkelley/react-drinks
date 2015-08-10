_ = require 'lodash'

# order:
#   glass-background
#   ice
#   drink color (masked?)
#   glass-foreground
#   citrus
#   garnish
#   extras

# icrt = ??? some kind of ice probably, but doesn't appear in the UI and all the pictures are blank
# lb = ??? something in the shape of the glass, maybe the mask for the color?
# lt = ??? something in the shape of the top of the glass

array2asset = (array, previewAssetSuffix) ->
  return _.map array, ([ display, assetKey, previewAssetName ]) ->
    return { display, assetKey, previewAssetName : "#{assetKey}-#{previewAssetSuffix}" }

GLASSES = array2asset [
  [ 'Rocks', 'roc' ]
  [ 'Collins', 'col' ]
  [ 'Highball', 'hib' ]
  [ 'Snifter', 'sni' ]
  [ 'Coupe', 'cou' ]
  [ 'Cocktail', 'mar' ]
  [ 'Nick & Nora', 'nan' ]
  [ 'Port', 'por' ]
  [ 'Flute', 'flu' ]
  [ 'Irish', 'irs' ]
  [ 'Hurricane', 'tro' ]
  [ 'Julep', 'jul' ]
  [ 'Mule', 'mos' ]
  [ 'Tiki', 'tik' ]
  [ 'Punch', 'pun' ]
], 'vi'

BACKGROUND_KEY = 'gbk'
FOREGROUND_KEY = 'gfg'

ICE = array2asset [
  [ 'Huge', 'ihu' ]
  [ 'Cubed', 'icu' ]
  [ 'Crushed', 'icr' ]
], 'ii'

CITRUS = array2asset [
  [ 'Lemon Peel', 'lep' ]
  [ 'Lemon Wedge', 'les' ]
  [ 'Lemon Twist', 'let' ]
  [ 'Lime Peel', 'lip' ]
  [ 'Lime Wedge', 'lis' ]
  [ 'Lime Twist', 'lit' ]
  [ 'Orange Peel', 'orp' ]
  [ 'Orange Wedge', 'ors' ]
  [ 'Orange Twist', 'ort' ]
], 'gi'

GARNISH = array2asset [
  [ 'Apple Slice', 'aps' ]
  [ 'Celery', 'cel' ]
  [ 'Cherry', 'che' ]
  [ 'Cucumber Slice', 'cuc' ]
  [ 'Olive', 'olv' ]
  [ 'Pineapple', 'pine' ]
  [ 'Strawberry', 'strawb' ]
], 'gi'

EXTRAS = array2asset [
  [ 'Mint', 'mint' ]
  [ 'Straw', 'str' ]
  [ 'Salt', 'salt' ]
  [ 'Umbrella', 'umb' ]
  [ 'Whipped Cream', 'whip' ]
], 'gi'

module.exports = {
  GLASSES
  ICE
  CITRUS
  GARNISH
  EXTRAS
  BACKGROUND_KEY
  FOREGROUND_KEY
}
