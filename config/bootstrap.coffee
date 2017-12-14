module.exports =
  bootstrap: (cb) ->
    sails.config.trade.analyze()
    cb()
