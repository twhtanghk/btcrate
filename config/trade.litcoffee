    _ = require 'lodash'
    {WebsocketClient} = require 'gdax'
    {DataFrame} = require 'dataframe-js'

    Sample = require 'stampit-event-bus'
      .props 

sample data for analysis

        data: null

default sample data within 1 hour

        range: 3600000

override default range

      .init (opts = {}) ->
        _.extend @, _.pick(opts, 'range')

      .static
        split: ([start, end], step) ->
          (if step > 0 then [i, i + step] else [i + step, i]) for i in [start..end-step] by step

        predicate: ([start, end], step, field) ->
          ret = {}
          @split
            .apply @, arguments
            .map ([start, end]) ->
              ret[start] = (row) ->
                elem = row[field]
                start <= elem and elem < end
          ret

        groupBy: (df, field) ->
          reducer = (ret, group) ->
            ret[group.groupKey[field]] = group.group
            ret
          df?.groupBy(field).toCollection().reduce reducer, {}

        groupByFunc: (df, conditions) ->
          init = (ret, predicate, name) ->
            ret[name] = []
            ret
          ret = _.reduce conditions, init, {}
          _.each conditions, (predicate, name) ->
            df?.toCollection().map (row) ->
              if predicate row
                ret[name].push row
          _.each ret, (data, name) ->
            ret[name] = new DataFrame ret[name], df?.listColumns()
          ret

        distinct: (df, field) ->
          df.distinct(field).toDict()[field]
 
        stat: (df) ->
          volume: df.count()
          size: df.stat.sum 'size'
          price: df.stat.mean 'price'
          min: df.stat.min 'price'
          max: df.stat.max 'price'
              
        go: (df) ->
          ret = @groupBy df, 'side'
          _.each ret, (df, side) =>
            ret[side] = @groupBy(df, 'product_id')
            _.each ret[side], (df, product) =>
              ret[side][product] = @stat df
          ret

      .methods

add elem, filter sample data fall within predefined time range and emit updated

        push: (elem...) ->
          if @data?
            @data = @data.push.apply @data, elem
          else
            @data = new DataFrame elem
          @data = @data.filter (elem) =>
            start = new Date(Date.now() - @range)
            start <= elem.get('time')
          @emit 'updated'

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

save data into trade model

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
          @sample = @Sample range: 300000
          @ws.on 'matched data', (data) =>
            @sample.push data
