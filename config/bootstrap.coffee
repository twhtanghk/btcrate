_ = require 'lodash'
schedule = require 'node-schedule'

module.exports =
  bootstrap: (cb) ->
    _.map sails.config.crontab, (task, at) ->
      schedule.scheduleJob at, task
    cb()
