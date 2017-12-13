module.exports =
  bootstrap: (cb) ->
    sails.config.trade.init()
    cb()
