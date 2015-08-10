_                   = require 'lodash'
React               = require 'react/addons'
{ PureRenderMixin } = React.addons

imageConstants = require './imageConstants'

ASSET_SHAPE = React.PropTypes.shape {
  assetKey : React.PropTypes.string.isRequired
}

assetUrlFor = (glassAssetKey, assetKey) ->
  return "/assets/img/drinks-parts/#{glassAssetKey}-#{assetKey}_420@2x.png"

assetKeysFor = (arrays...) ->
  return _.chain arrays
    .flatten true
    .pluck 'assetKey'
    .value()


RecipeImage = React.createClass {
  displayName : 'RecipeImage'

  mixins : [ PureRenderMixin ]

  propTypes :
    glass      : React.PropTypes.oneOf(assetKeysFor(imageConstants.GLASSES)).isRequired
    drinkColor : React.PropTypes.string # not yet required # hexcode, for now
    ice        : React.PropTypes.oneOf assetKeysFor(imageConstants.ICE)
    extras     : React.PropTypes.arrayOf(
      React.PropTypes.oneOf(
        assetKeysFor(imageConstants.CITRUS, imageConstants.GARNISH, imageConstants.EXTRAS)
    ))

  render : ->
    layers = _.chain [
        imageConstants.BACKGROUND_KEY
        @props.ice
        imageConstants.FOREGROUND_KEY
        @props.extras
      ]
      .flatten()
      .compact()
      .value()

    <div className='recipe-image'>
      {_.map layers, (l) => <img src={assetUrlFor @props.glass, l} className='layer'/>}
    </div>
}

module.exports = RecipeImage
