_ = require 'lodash'

module.exports =

  schema: true

  autoCreatedAt: false

  autoUpdatedAt: false

  attributes:

    product:
      type: 'string'

    date:
      type: 'datetime'

    open:
      type: 'float'

    close:
      type: 'float'

    low:
      type: 'float'

    high:
      type: 'float'

    volume:
      type: 'float'

  afterCreate: (created, cb) ->
    @publishCreate created
    cb()
