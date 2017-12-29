    _ = require 'lodash'
    {WebsocketClient} = require 'gdax'
    {DataFrame} = require 'dataframe-js'
    stampit = require 'stampit'

    Sample = stampit()
      .props 

sample data for analysis

        data: []

default sample data fall within 5 min

        range: 5 * 60 * 1000

      .init (opts = {}) ->
        _.extend @, _.pick(opts, 'range')
        job = =>
          [first, ..., last] = @data
          df = new DataFrame @data
          @data = []
          df
            .groupBy 'product_id'
            .toCollection()
            .map ({groupKey, group}) =>
              [first, ..., last] = group.toCollection()
              date = first.time.getTime()
              date = new Date(date - date % @range)
              sails.models.trade
                .create
                  product: groupKey.product_id
                  date: date
                  open: first.price
                  close: last.price
                  low: group.stat.min 'price'
                  high: group.stat.max 'price'
                  volume: group.stat.sum 'size'
                .catch sails.log.error
          setTimeout job, @slot()[1] - Date.now()
        setTimeout job, @slot()[1] - Date.now()
        @

      .methods

add elem, filter sample data fall within predefined time range and emit updated

        push: (elem...) ->
          @data.push.apply @data, elem

return current time slot [start time, end time]

        slot: ->
          [
            Math.floor(Date.now() / @range) * @range
            Math.ceil(Date.now() / @range) * @range
          ]

    class Trade extends WebsocketClient
      @transform: (data) ->
        if data.size?
          data.size = parseFloat data.size
        if data.price?
          data.price = parseFloat data.price
        data.time = new Date data.time
        data

      ws: null
      type: []
      ratelist: [
        'BTC-USD'
        'ETH-BTC'
        'ETH-USD'
      ]

      constructor: (opts = {}) ->
        _.extend @, _.pick(opts, 'ratelist')
        super @ratelist, null, null, channels: [ 'ticker' ]
        @on 'error', (err) ->
          sails.log.error err
        @on 'close', ->
          sails.log.error "#{new Date()} gdax ws unexpectedly closed"
        @on 'message', (data) =>

collect type list

          if data.type not in @type
            @type.push data.type

emit data updated

          if data.type == 'match'
            @emit 'matched data', Trade.transform data

        @on 'matched data', (data) ->

save data into gdax model

          sails.models.gdax?.create data
            .catch sails.log.error

      debug: (enable = true) ->
        if enable
          @on 'matched data', sails.log.debug
        else
          @removeListener 'matched data', sails.log.debug

    module.exports =
      trade:
        ws: new Trade()
        analyze: ->
          @slot = Sample()
          @ws.on 'matched data', (data) =>
            @slot.push data
