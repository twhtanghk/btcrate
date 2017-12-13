{WebsocketClient} = require 'gdax'

transform = (data) ->
  data.size = parseFloat data.size
  data.price = parseFloat data.price
  data

module.exports =
  trade:
    type: []
    ratelist: [
      'BTC-USD'
      'ETH-BTC'
      'ETH-USD'
    ]
    init: ->
      ws = new WebsocketClient @ratelist, null, null, channels: [ 'ticker' ]
      ws
        .on 'message', (data) =>
          if data.type not in @type
            @type.push data.type
          if data.type == 'match'
            sails.models.trade
              .create transform data
              .catch sails.log.error
        .on 'error', sails.log.error
        .on 'close', ->
          sails.log.error 'gdax ws closed'
