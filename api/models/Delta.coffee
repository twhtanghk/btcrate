_ = require 'lodash'

module.exports =

  schema: true

  attributes:

    side:
      type: 'string'

    product:
      type: 'string'

    tmStart:
      type: 'datetime'

    tmEnd:
      type: 'datetime'

    deltaVolume:
      type: 'float'

    deltaSize:
      type: 'float'

    deltaPrice:
      type: 'float'

    deltaMin:
      type: 'float'

    deltaMax:
      type: 'float'
