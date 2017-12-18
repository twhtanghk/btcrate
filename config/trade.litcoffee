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

cut input array with specified bins
see [pandas.cut](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.cut.html)
return 
  out: [(s1, e1], (s2, e2], ..., (sn, en]]
  predictate: [p1(elem), p2(elem), ..., pn(elem)]

        cut: (array, bins = 10) ->
          if typeof bins == 'number'
            [min, max] = [_.min(array), _.max(array)]
            extend = (max - min) * 0.001
            [min, max] = [min - extend, max + extend]
            step = (max - min) / bins
            out = ([i, i + step] for i in [min..max] by step)
            @cut array, out
          else if bins instanceof Array
            out = ([bins[i], bins[i + 1]] for i in [0..bins.length - 2])
            out: out
            predicate: out.map ([start, end]) -> (elem) ->
              start < elem and elem <= end
          else
            throw new Error "bins should be number or array"

cut input df for field with step interval
convert field if fieldConv is specified
return
  bin: [[s1, e1), [s2, e2), ..., [sn, en)]
  predictate: [p1(elem), p2(elem), ..., pn(elem)]

        cutDf: (df, field, bins = 10, fieldConv = null) ->
          array = df.select(field).toDict()[field]
          if fieldConv?
            array = array.map fieldConv
          {out, predicate} = @cut array, bins
          out: out
          predicate: predicate.map (cond) -> (row) ->
            cond row.get field
          
date field conversion for above cut and cutDf

        dateConv: (dt) ->
          dt.getTime()

date bins for input array with specified interval in millisecond (default 5min)

        dateBins: (array, interval = 300000) ->
          [min, max] = [_.min(array), _.max(array)]
          ret =
            min: [
              Math.floor(min / interval) * interval
              min % interval
            ]
            max: [
              Math.ceil(max / interval) * interval
              max % interval
            ]
          min = if ret.min[1] == 0 then ret.min[0] - interval else ret.min[0]
          max = ret.max[0]
          i for i in [min..max] by interval

group input df for field with step interval
convert field if fieldConv is specified
return
  start1: df with rows fall within [start1, end1)
  start2: df with rows fall within [start2, end2)
  ...
  startn: df with rows fall within [startn, endn)

        groupByRange: (df, field, bins = 10, fieldConv = null) ->
          {out, predicate} = @cutDf.apply @, arguments
          keys = out.map ([start, end]) ->
            start
          values = out.map ->
            new DataFrame [], df.listColumns()
          df.map (row) ->
            predicate.map (cond, i) ->
              if cond row
                values[i] = values[i].push row
          ret = {}
          _.each keys, (key, i) ->
            ret[key] = values[i]
          ret
            
        groupBy: (df, field) ->
          reducer = (ret, group) ->
            ret[group.groupKey[field]] = group.group
            ret
          df?.groupBy(field).toCollection().reduce reducer, {}

        distinct: (df, field) ->
          df.distinct(field).toDict()[field]
 
        stat: (df) ->
          volume: df.count()
          size: df.stat.sum 'size'
          price: df.stat.mean 'price'
          min: df.stat.min 'price'
          max: df.stat.max 'price'
              
transform raw df into stat df by time with specified time interval
e.g. trade.Sample.statByTime(trade.sample.data).sortBy('product').show()

        statByTime: (df, interval = 300000) ->
          ret = new DataFrame [], [
            'side'
            'product'
            'time'
            'volume'
            'size'
            'price'
            'min'
            'max'
          ]
          _.each @groupBy(df, 'side'), (df, side) =>
            ret[side] = @groupBy(df, 'product_id')
            _.each ret[side], (df, product) =>
              field = 'time'
              bins = @dateBins df.select(field).toDict()[field]
              ret[side][product] = @groupByRange df, field, bins, @dateConv
              _.each ret[side][product], (df, time) =>
                ret = ret.push _.extend @stat(df), 
                  side: side
                  product: product
                  time: time
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

          sails.models.trade?.create data
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
