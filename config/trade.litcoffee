    _ = require 'lodash'
    {WebsocketClient} = require 'gdax'
    stampit = require 'stampit'

    Sample = require 'stampit-event-bus'
      .props 

sample data for analysis

        data: []

default sample data within 1 hour

        range: 3600000

time interval for analysis

        interval: 300000

override default range and interval

      .init (opts = {}) ->
        _.extend @, _.pick(opts, 'range', 'interval')

      .methods

add elem, filter sample data fall within predefined time range and emit updated

        push: (elem...) ->
          @data.push.apply @data, elem
          @data = _.filter @data, (elem) =>
            start = new Date(Date.now() - @range)
            start <= elem.time
          @emit 'updated'
      
    class Trade extends WebsocketClient
      @transform: (data) ->
        data.size = parseFloat data.size
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
      trade:
        ws: new Trade()
        Sample: Sample
        analyze: ->
          @sample = @Sample()
          @ws.on 'matched data', (data) =>
            @sample.push data
