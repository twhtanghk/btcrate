_ = require 'lodash'

module.exports =
  tableName: 'rate'

  schema: true

  attributes:

    type:
      type: 'string'

    trade_id:
      type: 'integer'

    side:
      type: 'string'

    size:
      type: 'float'

    price:
      type: 'float'

    product_id:
      type: 'string'

    time:
      type: 'datetime'

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
