module.exports =
  bootstrap: (cb) ->
    sails.io.on 'connection', (socket) ->
      sails.models.trade.watch socket
    sails.config.trade.analyze()
    cb()
