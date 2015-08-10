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
    maskTop  = "url(#{assetUrlFor(@props.glass, 'lt')})"
    maskBody = "url(#{assetUrlFor(@props.glass, 'lb')})"

    layers = _.chain [
        imageConstants.BACKGROUND_KEY
        @props.ice
        <div className='layer color' style={{
          backgroundColor : 'rgba(0, 0, 255, 0.5)'
          maskImage       : maskBody
          WebkitMaskImage : maskBody
        }}/>
        <div className='layer color' style={{
          backgroundColor : 'rgba(0, 0, 255, 0.5)'
          maskImage       : maskTop
          WebkitMaskImage : maskTop
        }}/>
        imageConstants.FOREGROUND_KEY
        @props.extras
      ]
      .flatten()
      .compact()
      .value()


    <div className='recipe-image'>
      {_.map layers, (layer) =>
        if _.isString layer
          <img src={assetUrlFor @props.glass, layer} className='layer'/>
        else
          layer}
    </div>
}

module.exports = RecipeImage
