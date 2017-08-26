_ = require 'lodash'

module.exports =
  tableName: 'rate'

  schema: true

  attributes:

    from:
      type: 'string'
      required: true

    to:
      type: 'string'
      required: true

    rate:
      type: 'float'
      required: true

  findDelta: (currency = 'HKD', limit = 100) ->
    @find to: currency
      .sort createdAt: -1
      .limit limit
      .then (rates) ->
        [last, rates...] = rates
        _.map rates, (curr) ->
          delta = (curr.rate - last.rate) / (curr.createdAt - last.createdAt)
          last = curr
          delta
