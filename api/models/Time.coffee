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

    volume:
      type: 'integer'

    size:
      type: 'float'

    price:
      type: 'float'

    min:
      type: 'float'

    max:
      type: 'float'
