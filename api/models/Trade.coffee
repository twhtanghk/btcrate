_ = require 'lodash'

module.exports =

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

  collection: ->
    new Promise (resolve, reject) =>
      @native (err, collection) ->
        if err?
          return reject err
        resolve collection

  period: (tmStart, tmEnd) ->
    time:
      $gte: tmStart
      $lte: tmEnd

  mapReduce: (m, r, opts) ->
    @collection()
      .then (collection) ->
        collection.mapReduce m, r, _.defaults(out: inline: 1, opts)

  findType: ->
    @collection()
      .then (collection) ->
        collection.distinct 'type'

  findWithin: (tmStart, tmEnd) ->
    @find
      time:
        '>=': tmStart
        '<=': tmEnd

  findVolWithin: (tmStart, tmEnd) ->
    m = ->
      emit @product_id, 1
    r = (trade, list) ->
      list.length
    @mapReduce m, r, query: @period tmStart, tmEnd

  findSizeWithin: (tmStart, tmEnd) ->
    m = ->
      emit @product_id, @size
    r = (trade, list) ->
      Array.sum list
    @mapReduce m, r, query: @period tmStart, tmEnd

  findAvgPriceWithin: (tmStart, tmEnd) ->
    m = ->
      emit @product_id, @price
    r = (trade, list) ->
      Array.sum(list) / list.length
    @mapReduce m, r, query: @period(tmStart, tmEnd)
