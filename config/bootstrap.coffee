_ = require 'lodash'
cron = require 'node-schedule'
init =
  socket: ->
    sails.io.on 'connection', (socket) ->
      sails.models.time.watch socket
      sails.models.delta.watch socket

module.exports =
  bootstrap: (cb) ->
    init.socket()
    sails.config.trade.analyze()
    _.map sails.config.cron, (job, at) ->
      cron.scheduleJob at, job
    cb()
