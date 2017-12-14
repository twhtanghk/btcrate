    {WebsocketClient} = require 'gdax'

    class Trade extends WebsocketClient
      @transform: (data) ->
        data.size = parseFloat data.size
        data.price = parseFloat data.price
        data

      ws: null
      type: []
      ratelist: [
        'BTC-USD'
        'ETH-BTC'
        'ETH-USD'
      ]

      constructor: ->
        super @ratelist, null, null, channels: [ 'ticker' ]
        @on 'error', (err) ->
          sails.log.error err
        @on 'close', ->
          sails.log.error "#{new Date()} gdax ws unexpectedly closed"
        @on 'message', (data) =>

collect type list

          if data.type not in @type
            @type.push data.type

filter matched data only

          if data.type == 'match'
            @emit 'matched data', Trade.transform data

        @on 'matched data', (data) ->

save matched data into trade model

          sails.models.trade
            .create data
            .catch sails.log.error

      debug: (enable = true) ->
        if enable
          @on 'matched data', sails.log.debug
        else
          @removeListener 'matched data', sails.log.debug

    module.exports =
      trade: new Trade()
