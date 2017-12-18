_ = require 'lodash'
cron = require 'node-schedule'

module.exports =
  bootstrap: (cb) ->
    sails.config.trade.analyze()
    _.map sails.config.cron, (job, at) ->
      cron.scheduleJob at, job
    cb()
