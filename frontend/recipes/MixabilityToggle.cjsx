_          = require 'lodash'
React      = require 'react/addons'
classnames = require 'classnames'

{ PureRenderMixin } = React.addons

MIXABILITY_FILTER_NAMES =
  mixable          : 'Mixable'
  nearMixable      : '1 Missing'
  notReallyMixable : '2+ Missing'

MixabilityToggle = React.createClass {
  displayName : 'MixabilityToggle'

  mixins : [ PureRenderMixin ]

  propTypes :
    mixabilityToggles : React.PropTypes.object.isRequired
    onToggle          : React.PropTypes.func.isRequired

  render : ->
    <div className='mixability-toggle'>
      {for key, setting of @props.mixabilityToggles
        <div
          className={classnames 'option', { 'selected' : setting }}
          onTouchTap={_.partial @props.onToggle, key}
          key={key}
        >
          {MIXABILITY_FILTER_NAMES[key]}
        </div>}
    </div>
}

module.exports = MixabilityToggle
