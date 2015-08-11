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

hex2rgb = (hex) ->
  return [ hex >> 16 & 0xff, hex >> 8 & 0xff, hex & 0xff ]

RecipeImage = React.createClass {
  displayName : 'RecipeImage'

  mixins : [ PureRenderMixin ]

  propTypes :
    glass  : React.PropTypes.oneOf(assetKeysFor(imageConstants.GLASSES)).isRequired
    color  : (props, propName) ->
      if not /^#[0-9a-fA-F]{6,8}$/.test props[propName]
        return new Error('color prop should be a 6- or 8-digit hex number with leading #')
    ice    : React.PropTypes.oneOf assetKeysFor(imageConstants.ICE)
    extras : React.PropTypes.arrayOf(
      React.PropTypes.oneOf(
        assetKeysFor(imageConstants.CITRUS, imageConstants.GARNISH, imageConstants.EXTRAS)
    ))

  render : ->
    maskTop  = "url(#{assetUrlFor(@props.glass, imageConstants.MASK_TOP_KEY)})"
    maskBody = "url(#{assetUrlFor(@props.glass, imageConstants.MASK_BODY_KEY)})"
    color = @props.color.replace '#', '0x'
    if @props.color.length == 8
      [ r, g, b ] = hex2rgb color
      a = 0.5
    else
      [ r, g, b ] = hex2rgb color[0...8]
      a = (color & 0xff) / 255

    colorRgba = "rgba(#{r}, #{g}, #{b}, #{a})"

    layers = _.chain [
        imageConstants.BACKGROUND_KEY
        @props.ice
        # This stupid trick takes advantage of the fact that we have empty images of exactly the right size.
        # Basically, it ensures that the mask is applied to an element that's the same size as the other
        # images but without having to do any weird CSS bullshit (if it's even possible) or examine the size
        # of the images in js.
        <img
          src={assetUrlFor @props.glass, 'icrt'}
          className='layer color'
          key='drink-body'
          style={{
            backgroundColor : colorRgba
            maskImage       : maskBody
            WebkitMaskImage : maskBody
        }}/>
        <img
          src={assetUrlFor @props.glass, 'icrt'}
          className='layer color'
          key='drink-top'
          style={{
            backgroundColor : colorRgba
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
          return <img src={assetUrlFor @props.glass, layer} className='layer' key={layer}/>
        else
          return layer}
    </div>
}

module.exports = RecipeImage
