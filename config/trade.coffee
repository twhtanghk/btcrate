_ = require 'lodash'
{WebsocketClient} = require 'gdax'
{Readable, Transform} = require 'stream'

class TradeStream extends Readable
  @transform: (data) ->
    data.size = parseFloat data.size
    data.price = parseFloat data.price
    data.time = new Date data.time
    data

  constructor: (opts) ->
    @ws = opts.ws
    @ws
      .on 'message', (data) =>
        if data.side == 'buy' and data.type == 'match'
          @push TradeStream.transform data
      .on 'error', sails.log.error
      .on 'close', ->
        sails.log.error 'gdax ws unexpectedly closed'
    super _.defaults objectMode: true, opts

  _read: ->

class Trade
  @_ws: null
  @_stream: null
  @_type: []
  @_ratelist: [
    'BTC-USD'
    'ETH-BTC'
    'ETH-USD'
  ]

  @ws: ->
    @_ws ?= new WebsocketClient @_ratelist, null, null, channels: ['ticker']

  @stream: ->
    @_stream ?= new TradeStream ws: @ws()

log = new Transform
  readableObjectMode: true
  writableObjectMode: true
  transform: (data) ->
    console.log data
    @push data

agg = require 'timestream-aggregates'
concat = require 'concat-stream'

module.exports =
  trade:
    stream: ->
      Trade.stream()
    debug: (flag = true) ->
      if flag
        @stream().pipe log
      else
        @stream().unpipe log
    agg: ->
      Trade.stream()
        .pipe concat console.log
